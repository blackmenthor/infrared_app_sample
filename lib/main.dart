import 'package:flutter/material.dart';
import 'package:infrared_app/constants.dart' as Constants;
import 'package:ir_sensor_plugin/ir_sensor_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lamp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Lamp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isInfraredAvailable = false;
  bool _isLampOn = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _setPersistentState(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(Constants.LAMP_STATE_KEY, value);
  }

  Future<bool> _getPersistentState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool alreadyContainsKey = sharedPreferences.containsKey(Constants.LAMP_STATE_KEY);
    if (alreadyContainsKey) {
      return sharedPreferences.getBool(Constants.LAMP_STATE_KEY);
    } else {
      // FRESH APP INSTALL
      // SET VALUE TO TRUE

      await sharedPreferences.setBool(Constants.LAMP_STATE_KEY, true);
      return true;
    }
  }

  void _init() async {
    final bool hasIrEmitter = await IrSensorPlugin.hasIrEmitter;

    setState(() {
      this._isInfraredAvailable = hasIrEmitter;
    });

    bool currentState = await _getPersistentState();
    setState(() {
      this._isLampOn = currentState;
    });
  }

  void _recalibrateState() async {
    // RESET PERSISTENT STATE
    await _setPersistentState(true);

    setState(() {
      this._isLampOn = true;
    });
  }

  void _transmitIRSignal() async {
    try {
      await IrSensorPlugin.transmitListInt(list: Constants.LAMP_FREQUENCY);

      bool newState = !this._isLampOn;
      setState(() {
        this._isLampOn = newState;
      });

      _setPersistentState(newState);
    } catch (exception) {
      // infrared transmission fails, don't change the state
    }
  }

  Widget _noInfraredWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Text(
          "No Infrared transmitter available on this device!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _lampImage(BuildContext context) {
    final size = 64.0;
    return this._isLampOn ?
        Image(
          image: AssetImage("res/images/lamp_on.png"),
          height: size,
          width: size,
        ) :
        Image(
          image: AssetImage("res/images/lamp_off.png"),
          height: size,
          width: size,
        );
  }

  Widget _infraredAvailableWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _lampImage(context),
            RaisedButton(
              child: Text(
                this._isLampOn ? "Turn Off" : "Turn On"
              ),
              onPressed: _transmitIRSignal,
            ),
            RaisedButton(
              child: Text(
                "Recalibrate Lamp State"
              ),
              onPressed: _recalibrateState,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: this._isInfraredAvailable ? _infraredAvailableWidget(context)
          : _noInfraredWidget(context),
    );
  }
}
