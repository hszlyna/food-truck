import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../FT_Conf/FTDetail.dart';
import '../Forma/FormaDat/_FTPDat.dart';
// Centralized Data

class FTSelect extends StatefulWidget {
  const FTSelect({Key? k}) : super(key: k);

  @override
  FTSelectState createState() => FTSelectState();
}

class FTSelectState extends State<FTSelect> {
  final List<Map<String, String>> foodCat = [
    {'name': 'Da Grill Mastas', 'img': 'assets/da_grill_mastas.png'},
    {'name': 'Spice Caravan', 'img': 'assets/spice_caravan.png'},
    {'name': 'Sweet Treat Wheels', 'img': 'assets/sweet_treat_wheels.png'},
    {'name': 'The Wok Working', 'img': 'assets/the_wok_working.png'},
  ];

  bool visSht = false;

  bool fillBook() {
    final ftPDat = Provider.of<FTPDat>(context, listen: false);
    return ftPDat.hasPax();
  }

  @override
  Widget build(BuildContext context) {
    final ftPDat = Provider.of<FTPDat>(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text("Select Food Truck"),
        actions: [
          InkWell(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              setState(() {
                visSht = !visSht; // Toggle visibility
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent,
                ),
                child: Icon(
                  visSht ? Icons.close : Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: foodCat.length,
            itemBuilder: (ctx, idx) {
              final cat = foodCat[idx];
              final isSel = ftPDat.isFTSel(cat['name']!);

              return GestureDetector(
                onTap: () async {
                  if (Provider.of<FTPDat>(context, listen: false)
                      .isFTSel(cat['name']!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${cat['name']} has already been selected.'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final res = await Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (ctx) => FTDetail(cat: cat['name']!),
                    ),
                  );
                  if (res != null) {
                    setState(() {
                      ftPDat.addPax(res);
                    });
                  }
                },
                child: Card(
                  color: isSel ? Colors.white54 : Colors.white,
                  elevation: 3,
                  clipBehavior:
                      Clip.antiAlias, // Clip the image within the card
                  child: Stack(
                    children: [
                      Image.asset(cat['img']!,
                          width: double.infinity,
                          height: 120.0,
                          fit: BoxFit.cover),
                      Positioned(
                        bottom: 10.0,
                        left: 10,
                        right: 10,
                        child: Text(
                          cat['name']!,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center, // Adjust text color
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (visSht)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.35,
              maxChildSize: 0.95,
              builder: (ctx, ctrl) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 12)
                    ],
                  ),
                  child: CustomScrollView(
                    controller: ctrl,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SliverAppBar(
                        title: const Text(
                          'Selected Packages',
                          style: TextStyle(color: Colors.black87, fontSize: 18),
                        ),
                        backgroundColor: Colors.white,
                        primary: false,
                        pinned: true,
                        centerTitle: false,
                        elevation: 0,
                        actions: [
                          if (ftPDat.hasPax())
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  ftPDat.clrPax();
                                });
                              },
                              child: const Text(
                                "Clear All",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, idx) {
                            final pck = ftPDat.selPax[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Card(
                                child: ListTile(
                                  title: Text('${pck['ft']} (${pck['pax']})'),
                                  subtitle: Text(
                                    'RM${pck['prois'].toStringAsFixed(2)}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        ftPDat.rmvPax(idx);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: ftPDat.selPax.length,
                        ),
                      ),
                      if (!fillBook())
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No food truck packages selected yet.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
