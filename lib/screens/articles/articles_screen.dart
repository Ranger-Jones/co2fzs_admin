import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/article.dart';
import 'package:co2fzs_admin/screens/articles/add_article_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/article_info.dart';
import 'package:flutter/material.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Artikel",
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddArticleScreen(),
          ),
        ),
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("articles")
            .orderBy("datePublished")
            .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => ArticleInfo(
              snap: Article.fromSnap(snapshot.data!.docs[index]),
            ),
          );
        },
      ),
    );
  }
}
