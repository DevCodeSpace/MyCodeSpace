import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_order/model/order_model.dart';

class BillReceipt extends StatelessWidget {
  final RestaurantOrderModel order;

  const BillReceipt({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'DineAssist AI'.toUpperCase(),
                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black87),
                ),
                Text('Digital Receipt', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], letterSpacing: 1)),
              ],
            ),
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
                        ),
                        Text('Qty: ${item.quantity}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.price}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              Text(
                '₹${order.total}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFFD4AF37), // Gold color
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              order.suggestion,
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Thank you for dining with us!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }
}
