class SelectedItem {
  final int id;
  final String name;
  final String price;
  int quantity; // <-- remove final

  SelectedItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
  };

  factory SelectedItem.fromMap(Map<String, dynamic> map) => SelectedItem(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    quantity: map['quantity'],
  );
}
