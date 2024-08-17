import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  List posts = [];
  int page = 1;
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.amber,
        body: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          controller: scrollController,
          itemCount: isLoadingMore ? posts.length + 1 : posts.length,
          itemBuilder: (context, index) {
            if (index < posts.length) {
              final post = posts[index];
              final title = post['title']['rendered'];
              final description =
                  post['title']['rendered']; //['seoDescription'];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    title,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    description,
                    maxLines: 1,
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> fetchPosts() async {
    final String url =
        'https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=10&page=$page';
    print('$url');
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        posts = posts + json;
      });
    } else {
      print('Unexpected response');
    }
  }

  Future<void> _scrollListener() async {
    if (isLoadingMore) return;

    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      print('Scroll Listener called!');
      page += 1;
      setState(() {
        isLoadingMore = true;
      });
      await fetchPosts();
      setState(() {
        isLoadingMore = false;
      });
    } else {
      print('Don\'t call');
    }
  }
}
