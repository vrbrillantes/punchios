import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;

  StarRating({this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color});

  Widget buildStar(BuildContext context, int index) {
    Image icon;
    if (index >= rating) {
      icon = Image.asset(
        'images/star@2x.png',
        height: 30,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = Image.asset(
        'images/star-active@2x.png',
        height: 30,
      );
    } else {
      icon = Image.asset(
        'images/star-active@2x.png',
        height: 30,
      );
    }
    return new InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(child: Row(children: List.generate(starCount, (index) => buildStar(context, index)), mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceEvenly,), padding: EdgeInsets.all(16),);
  }
}