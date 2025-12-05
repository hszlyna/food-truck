class LMItm {
  final String title, desc, img;
  final double prois;

  LMItm({
    required this.title,
    required this.desc,
    required this.prois,
    required this.img,
  });
}

class FTPax {
  final String fTrak;
  final Map<String, List<LMItm>> pax;

  FTPax({ required this.fTrak, required this.pax });

  double gProisPax(String paxName) {
    double totProis = 0;
    for(LMItm itm in pax[paxName]!){
      totProis += itm.prois;
    }
    return totProis;
  }
}

class FTDat {
  final List<FTPax> ft = [
    FTPax(
      fTrak: 'Da Grill Mastas',
      pax: {
        'Grill Master\'s Feast': [
          LMItm(title: 'Juicy Grilled Ribeye Steak', desc: 'Delicious burger', img: 'burger.png', prois: 25.00),
          LMItm(title: 'Grilled Chicken Skewers', desc: 'Crispy fries', img: 'fries.png', prois: 12.00),
          LMItm(title: 'Baked Potato with Cheese and Beef', desc: 'Hearty side dish', img: 'baked_potato.png', prois: 5.00),
          LMItm(title: 'Seasonal Vegetables', desc: 'Fresh and healthy', img: 'veggies.png', prois: 3.00),
        ],
        'Classic Grill Night': [
          LMItm(title: 'Grilled Lamb Chops', desc: 'Juicy lamb chops', img: 'lamb_chops.png', prois: 20.00),
          LMItm(title: 'Grilled Corn on the Cob', desc: 'Sweet and savory', img: 'corn.png', prois: 3.00),
          LMItm(title: 'Garlic Bread', desc: 'Buttery and garlicky', img: 'garlic_bread.png', prois: 2.00),
          LMItm(title: 'Caesar Salad', desc: 'Classic salad', img: 'caesar_salad.png', prois: 5.00),
        ],
      },
    ),
    FTPax(
      fTrak: 'Spice Caravan',
      pax: {
        'Indian Spice Sensation': [
          LMItm(title: 'Butter Chicken with Naan', desc: 'Creamy and flavorful', img: 'butter_chicken.png', prois: 15.00),
          LMItm(title: 'Vegetable Samosas', desc: 'Crispy and savory', img: 'samosas.png', prois: 5.00),
          LMItm(title: 'Chana Masala with Rice', desc: 'Hearty and spicy', img: 'chana_masala.png', prois: 10.00),
          LMItm(title: 'Mango Lassi', desc: 'Refreshing drink', img: 'mango_lassi.png', prois: 4.00),
        ],
        'Spicy Thai Delight': [
          LMItm(title: 'Pad Thai with Shrimp', desc: 'Classic Thai dish', img: 'pad_thai.png', prois: 12.00),
          LMItm(title: 'Tom Yum Soup', desc: 'Fresh and tangy', img: 'tom_yum.png', prois: 8.00),
          LMItm(title: 'Spring Rolls', desc: 'Crispy and flavorful', img: 'spring_rolls.png', prois: 4.00),
          LMItm(title: 'Thai Iced Tea', desc: 'Sweet and refreshing', img: 'thai_iced_tea.png', prois: 3.00),
        ],
      },
    ),
    FTPax(
      fTrak: 'Sweet Treat Wheels',
      pax: {
        'Dessert Lover\'s Dream': [
          LMItm(title: 'Chocolate Lava Cake', desc: 'Indulgent dessert', img: 'lava_cake.png', prois: 8.00),
          LMItm(title: 'Vanilla Bean Ice Cream', desc: 'Classic ice cream', img: 'ice_cream.png', prois: 4.00),
          LMItm(title: 'Caramel Apple Tart', desc: 'Sweet and tart', img: 'apple_tart.png', prois: 6.00),
          LMItm(title: 'Hot Chocolate', desc: 'Warm and comforting', img: 'hot_chocolate.png', prois: 5.00),
        ],
        'Mini Dessert Sampler': [
          LMItm(title: 'Assorted Mini Cupcakes', desc: 'Colorful and tasty', img: 'mini_cupcakes.png', prois: 8.00),
          LMItm(title: 'Mini Cheesecake', desc: 'Creamy and delicious', img: 'mini_cheesecake.png', prois: 6.00),
          LMItm(title: 'Macarons', desc: 'French delicacy', img: 'macarons.png', prois: 10.00),
          LMItm(title: 'Fruit Tarts', desc: 'Fresh and fruity', img: 'fruit_tarts.png', prois: 7.00),
        ],
      },
    ),
    FTPax(
      fTrak: 'The Wok Working',
      pax: {
        'Asian Fusion Feast': [
          LMItm(title: 'Stir-Fried Noodles with Chicken and Vegetables', desc: 'Flavorful and healthy', img: 'stir_fry_noodles.png', prois: 12.00),
          LMItm(title: 'Crispy Spring Rolls', desc: 'Crispy and savory', img: 'spring_rolls.png', prois: 4.00),
          LMItm(title: 'Edamame', desc: 'Healthy snack', img: 'edamame.png', prois: 3.00),
          LMItm(title: 'Miso Soup', desc: 'Warm and comforting', img: 'miso_soup.png', prois: 2.00),
        ],
        'Spicy Noodle Sensation': [
          LMItm(title: 'Pad Thai with Tofu', desc: 'Vegetarian delight', img: 'pad_thai_tofu.png', prois: 10.00),
          LMItm(title: 'Spicy Ramen', desc: 'Flavorful and spicy', img: 'spicy_ramen.png', prois: 8.00),
          LMItm(title: 'Gyoza', desc: 'Dumplings', img: 'gyoza.png', prois: 6.00),
          LMItm(title: 'Green Tea', desc: 'Refreshing drink', img: 'green_tea.png', prois: 2.00),
        ],
      },
    ),
  ];
}