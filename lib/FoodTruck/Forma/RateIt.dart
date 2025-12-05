import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  double? _userRating;
  final List<Map<String, dynamic>> _reviews = [];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    // Validate the form and rating
    if (_userRating == null) {
      // Show error if rating is not provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide a rating."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the method
    }

    //If rating valid laah...
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Add the review to the list
        _reviews.add({
          'rating': _userRating,
          'review': _reviewController.text.trim(),
        });
        // Reset the input fields
        _userRating = null;
        _reviewController.clear();
      });

      // Provide success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reviews & Ratings")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rate the Food Trucks Booking:",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8.0),

                // Rating bar for user input
                RatingBar.builder(
                  initialRating: _userRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _userRating = rating;
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                // Text field for review input
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: "Write your review",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please write a comment.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text("Submit Review"),
                ),

                const SizedBox(height: 20.0),
                // Display Previous Reviews Section
                const Text("Previous Reviews:", style: TextStyle(fontSize: 18)),
                Expanded(
                  child: _reviews.isEmpty
                      ? const Center(child: Text("No reviews yet"))
                      : ListView.builder(
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              leading: RatingBarIndicator(
                                rating: review['rating'],
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 20.0,
                              ),
                              title: const Text("User Review"),
                              subtitle: Text(review['review']),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
