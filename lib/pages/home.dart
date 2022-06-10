import 'dart:io';

import 'package:app_avanzada/models/band.dart';
import 'package:app_avanzada/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    socketService.socket.on( 'active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload ){

    bands = (payload as List)
          .map( (band) => Band.fromMap(band))
          .toList();

    setState(() {});

  }

  @override
  void dispose() {
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');    
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(64, 63, 63, 404040),
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle( color: Colors.white ) ),
        backgroundColor: Color.fromRGBO(64, 63, 63, 404040),
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ( socketService.serverStatus == ServerStatus.Online )
            ? const Icon( Icons.check_circle, color: Colors.greenAccent )
            : const Icon(Icons.offline_bolt, color: Colors.red,)
          )
        ],
      ),
      body: Column(
        children: <Widget> [
          const SizedBox(height: 30,),

          _showGraph(),

          const SizedBox(height: 40,),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile( bands[i] )
            ),
          )
       ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon( Icons.add, color: Color.fromRGBO(64, 63, 63, 404040), ),
        elevation: 1,
        onPressed: addNewBand
      ),
   );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) => socketService.socket.emit('delete-band', { 'id' : band.id }),
       
      background: Container(
        padding: const EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white) ),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2), style: TextStyle( color: Color.fromRGBO(64, 63, 63, 404040)), ),
          backgroundColor: Colors.white ,
        ),
        title: Text( band.name, style: TextStyle(color: Colors.white), ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20, color: Colors.white) ),
        onTap: () => socketService.socket.emit('vote-band', {'id' : band.id } ),
        
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();
    
    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: const Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text )
              )
            ],
          )
        
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) => CupertinoAlertDialog(
          title: const Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList( textController.text )
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        )
      
    );

  }  

  void addBandToList( String name ) {
    
    

    if ( name.length > 1 ) {
      // Podemos agregar
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit( 'add-band', { 'name' : name } );
    }


    Navigator.pop(context);

  }

  Widget _showGraph (){
    
    Map<String, double> dataMap = {};
    
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.yellowAccent,
      Colors.pinkAccent,
      Colors.redAccent,
      Colors.purpleAccent,
      Colors.blueGrey,
      Colors.orangeAccent,
      Colors.amberAccent,
      Colors.cyanAccent,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
      Colors.indigoAccent,
      Colors.lightBlueAccent,
      Colors.lightGreenAccent,
      Colors.limeAccent,
      Colors.tealAccent
    ];
    return dataMap.isNotEmpty ? SizedBox(
      width: double.infinity,
      height: 200,
      
      child: PieChart(
      dataMap: dataMap,
      baseChartColor: Colors.grey[50]!.withOpacity(0.15),
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 70,
      chartRadius: MediaQuery.of(context).size.width / 2,
      colorList: colorList,
      chartType: ChartType.ring,
      ringStrokeWidth: 15,
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          color: Colors.white
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 2,
      ),
    )
      
    )
    : const LinearProgressIndicator();
  }

}