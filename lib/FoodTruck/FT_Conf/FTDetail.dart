import 'package:fdb/FoodTruck/Forma/FormaDat/_FTPDat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FTKlas.dart';

class FTDetail extends StatefulWidget {
  final String cat;
  const FTDetail({super.key, required this.cat});

  @override
  FTDetailState createState() => FTDetailState();
}

class FTDetailState extends State<FTDetail> {
  String? selFTPax;

  List<String> getPax() {
    for(var traki in FTDat().ft) {
      if(traki.fTrak == widget.cat) {
        return traki.pax.keys.toList();
      }
    }
    return [];
  }

  List<LMItm> gMnItm(String paxName) {
    for(var traki in FTDat().ft) {
      if(traki.fTrak == widget.cat) {
        return traki.pax[paxName] ?? [];
      }
    }
    return [];
  }

  double gSelPaxProis(String putPax) {
    for(var traki in FTDat().ft) {
      if(traki.fTrak == widget.cat){
        return traki.gProisPax(putPax);
      }
    }
      return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.cat} Packages")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 12),
                Text("Choose a package to see the menu items."),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: getPax().map((paxName) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selFTPax = paxName;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selFTPax == paxName ? Colors.purpleAccent : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(paxName, textAlign: TextAlign.center,)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'RM${gSelPaxProis(paxName).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          Text('Menu List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: gMnItm(selFTPax ?? '').length,
              itemBuilder: (ctx, idx) {
                final mn = gMnItm(selFTPax ?? '')[idx];
                return ListTile(
                  leading: Image.asset("assets/${mn.img}", width: 50, height: 50),
                  title: Text(mn.title),
                  subtitle: Text(mn.desc),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Padding(
            padding: EdgeInsets.zero,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size.fromHeight(48),
              ),
              onPressed: selFTPax == null || Provider.of<FTPDat>(context, listen: false).isFTSel(widget.cat)
                  ? null
                  : () {
                final ft = widget.cat;
                final pax = selFTPax;
                final prois = gSelPaxProis(pax!);
                Navigator.pop(context, {
                  'ft': ft,
                  'pax': pax,
                  'prois': prois
                });
              },
              child: Text(
                'Add Package',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
