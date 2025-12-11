import 'package:flashzone_web/src/model/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItemView extends ConsumerStatefulWidget {
  const CartItemView({super.key, required this.cartItem, required this.storeItem});
  final CartItem cartItem;
  final StoreItem? storeItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CartItemViewState();
}

class _CartItemViewState extends ConsumerState<CartItemView> {



  @override
  Widget build(BuildContext context) {
    if(widget.storeItem == null) {
      return const Center(
        child: Text("Item not found"),
        );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.network(widget.storeItem!.image, width: 100, height: 100, fit: BoxFit.cover,),
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
            ],
          )
        ],
      ),
    );
  }
}