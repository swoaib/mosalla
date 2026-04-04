import 'dart:async';
import '../repositories/mosalla_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import '../model/prayer_data.dart';
import '../model/mosalla_data.dart';
import '../extensions/date_extensions.dart';

class PrayerTimeProvider with ChangeNotifier{
  
  bool _isLoading = true;
  bool _isError = false;
  bool _countDownTomorrow = false;
  int? _activePrayer;
  int? _countDownPrayer;
  PrayerData? _prayerData;
  PrayerData? _todayPrayerData;
  DateTime? _endTime;
  late DateTime _date;
  StreamSubscription? _subscription;
  StreamSubscription? _todaySubscription;

  List<MosallaData> _mosallas = [];
  MosallaData? _selectedMosalla;
  String _selectedMosallaId = 'MSS';

  final MosallaRepository repository;

  PrayerTimeProvider({required this.repository}) {
    fetchMosallas();
  }

  StreamSubscription? _mosallasSubscription;

  void fetchMosallas() {
    _mosallasSubscription?.cancel();
    _mosallasSubscription = repository.getMosallasStream().listen(
      (data) {
        _mosallas = data;
        
        if (_mosallas.isNotEmpty) {
          try {
            _selectedMosalla = _mosallas.firstWhere((m) => m.id == _selectedMosallaId);
          } catch (_) {
            _selectedMosalla = _mosallas.first;
            _selectedMosallaId = _selectedMosalla!.id;
          }
          // Start the countdown listener separately
          _listenToToday();
          fetchPrayerTimes();
        }
        notifyListeners();
      },
      onError: (e) => debugPrint('Error fetching mosallas: $e')
    );
  }

  void setSelectedMosalla(String id) {
    if (_selectedMosallaId == id) return;
    _selectedMosallaId = id;
    try {
      _selectedMosalla = _mosallas.firstWhere((m) => m.id == id);
    } catch (_) {}
    _isLoading = true;
    notifyListeners();
    _listenToToday();
    fetchPrayerTimes();
  }

  void _listenToToday() {
    _todaySubscription?.cancel();
    final todayDocId = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _todaySubscription = repository.getPrayerTimesStream(_selectedMosallaId, todayDocId).listen((data) {
      _todayPrayerData = data;
      var sunriseSunset = getSunriseSunset(59.9139, 10.7522, 1, DateTime.now());
      _todayPrayerData!.sunrise = sunriseSunset.sunrise;
      _updateCountdown();
    });
  }

  void _updateCountdown() async {
    if (_todayPrayerData == null) return;
    DateTime time = DateTime.now();

    // 1. Calculate Active Prayer
    _activePrayer = null;
    if (_todayPrayerData!.fajr != null && time.isAfterTime(_todayPrayerData!.fajr!)) _activePrayer = 0;
    if (_todayPrayerData!.sunrise != null && time.isAfterTime(_todayPrayerData!.sunrise!)) _activePrayer = 1;
    if (_todayPrayerData!.duhr != null && time.isAfterTime(_todayPrayerData!.duhr!)) _activePrayer = 2;
    if (_todayPrayerData!.jumma != null && time.weekday == DateTime.friday && time.isAfterTime(_todayPrayerData!.jumma!)) _activePrayer = 6;
    if (_todayPrayerData!.asr != null && time.isAfterTime(_todayPrayerData!.asr!)) _activePrayer = 3;
    if (_todayPrayerData!.maghrib != null && time.isAfterTime(_todayPrayerData!.maghrib!)) _activePrayer = 4;
    if (_todayPrayerData!.isha != null && time.isAfterTime(_todayPrayerData!.isha!)) _activePrayer = 5;

    // 2. Calculate Countdown / Next Prayer
    _countDownTomorrow = false;
    _countDownPrayer = null;
    _endTime = null;
    
    if (_todayPrayerData!.isha != null && time.isBeforeTime(_todayPrayerData!.isha!)) { _endTime = _todayPrayerData!.isha!; _countDownPrayer = 5; }
    if (_todayPrayerData!.maghrib != null && time.isBeforeTime(_todayPrayerData!.maghrib!)) { _endTime = _todayPrayerData!.maghrib!; _countDownPrayer = 4; }
    if (_todayPrayerData!.asr != null && time.isBeforeTime(_todayPrayerData!.asr!)) { _endTime = _todayPrayerData!.asr!; _countDownPrayer = 3; }
    if (_todayPrayerData!.duhr != null && time.isBeforeTime(_todayPrayerData!.duhr!)) { _endTime = _todayPrayerData!.duhr!; _countDownPrayer = 2; }
    if (_todayPrayerData!.jumma != null && time.weekday == DateTime.friday && time.isBeforeTime(_todayPrayerData!.jumma!)) { _endTime = _todayPrayerData!.jumma!; _countDownPrayer = 6; }
    if (_todayPrayerData!.sunrise != null && time.isBeforeTime(_todayPrayerData!.sunrise!)) { _endTime = _todayPrayerData!.sunrise!; _countDownPrayer = 1; }
    if (_todayPrayerData!.fajr != null && time.isBeforeTime(_todayPrayerData!.fajr!)) { _endTime = _todayPrayerData!.fajr!; _countDownPrayer = 0; }

    DateTime? lastPrayerTime = _lastPrayer();
    if (lastPrayerTime != null && time.isAfterTime(lastPrayerTime)) {
      // It is past the LAST prayer today, find Fajr from TOMORROW
      final tomorrowDocId = DateFormat('dd-MM-yyyy').format(time.add(const Duration(days: 1)));
      final tomorrowData = await repository.getPrayerTime(_selectedMosallaId, tomorrowDocId);
      if (tomorrowData != null && tomorrowData.fajr != null) {
        _endTime = tomorrowData.fajr!;
        _countDownPrayer = 0;
        _countDownTomorrow = true;
      }
    }
    
    debugPrint("Countdown END TIME: ${_endTime}");
    notifyListeners();
  }

  DateTime? _lastPrayer(){
    if (_todayPrayerData == null) return null;
    if (_todayPrayerData!.isha != null) return _todayPrayerData!.isha!;
    if (_todayPrayerData!.maghrib != null) return _todayPrayerData!.maghrib!;
    if (_todayPrayerData!.asr != null) return _todayPrayerData!.asr!;
    if (_todayPrayerData!.duhr != null) return _todayPrayerData!.duhr!;
    if (_todayPrayerData!.fajr != null) return _todayPrayerData!.fajr!;
    return null;
  }

  void updateDisplay(){
    // triggered when countdown finishes, need extra seconds to surpass countdown time
    Future.delayed(const Duration(seconds: 2), () {
      _updateCountdown();
    });
  }

  void fetchPrayerTimes({DateTime? newDate}) async {
    _date = newDate ?? DateTime.now().add(const Duration(seconds: 10));
    final docId = DateFormat('dd-MM-yyyy').format(_date);
    final stream = repository.getPrayerTimesStream(_selectedMosallaId, docId);

    await _subscription?.cancel();
    _subscription = stream.listen(
      (prayerData) async {
        _prayerData = prayerData;
        var sunriseSunset = getSunriseSunset(59.9139, 10.7522, 1, _date);
        _prayerData!.sunrise = sunriseSunset.sunrise;

        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error: $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  void changeDate(bool isNext) {
    if (isNext) {
      fetchPrayerTimes(newDate: _date.add(const Duration(days: 1)));
    } else {
      fetchPrayerTimes(newDate: _date.subtract(const Duration(days: 1)));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _subscription?.cancel();
    await _todaySubscription?.cancel();
    await _mosallasSubscription?.cancel();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  int? get activePrayer {
    final now = DateTime.now();
    bool isToday = _date.year == now.year && _date.month == now.month && _date.day == now.day;
    return isToday ? _activePrayer : null;
  }
  int? get countDownPrayer => _countDownPrayer;
  PrayerData? get prayerData => _prayerData;
  DateTime? get endTime => _endTime;
  DateTime get date => _date;
  List<MosallaData> get mosallas => _mosallas;
  String get selectedMosallaId => _selectedMosallaId;
  MosallaData? get selectedMosalla => _selectedMosalla;
  bool get countDownTomorrow => _countDownTomorrow;
}
