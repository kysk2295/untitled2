class Book {
  final List<String> authors;
  final String contents;
  final List<String> havers;
  late bool like;
  late int like_count;
  final String publisher;
  final String title;
  final String imgUrl;
  final bool possible;

  Book(this.authors, this.contents, this.havers, this.publisher, this.title, this.imgUrl, this.like, this.like_count, this.possible);

  Map<String,dynamic> toMap(){
    return {
      'authors':authors,
      'contents':contents,
      'havers':havers,
      'like':like,
      'like_count':like_count,
      'publisher':publisher,
      'title':title,
      'imgUrl':imgUrl,
      'possible':possible
    };
  }
}