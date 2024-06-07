import 'package:flutter/material.dart';

class AboutUsNavFragment extends StatefulWidget {
  const AboutUsNavFragment({super.key});

  @override
  State<AboutUsNavFragment> createState() => _AboutUsNavFragmentState();
}

class _AboutUsNavFragmentState extends State<AboutUsNavFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "About Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Welcome to All Movies Download! We're passionate about providing a convenient and efficient way for users to access information about their favorite movies.\nOur app functions as a search engine, gathering data from various torrent sites to help you find the movies you love. We do not host any torrents or files for download ourselves; instead, we index information from other sources, much like how search engines like Google operate.\nAt All Movies Download, we prioritize user experience and content accessibility. Whether you're looking for classic films, the latest blockbusters, or niche favorites, our platform is designed to help you discover and access a wide range of movie titles.\nWe are committed to respecting copyright laws and intellectual property rights. If you believe that your copyrighted material has been improperly linked to our app, please reach out to us, and we will promptly investigate and address any concerns.\nThank you for choosing All Movies Download as your go-to destination for movie information. Happy watching!",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                "Contact Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "If you have any questions, feedback, or concerns, please feel free to contact us at admin@films365.org",
              )
            ],
          ),
        ),
      ),
    );
  }
}
