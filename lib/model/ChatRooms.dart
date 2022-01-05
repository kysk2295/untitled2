class ChatRooms{
  final String lastMsg;
  final String profileImg;
  final List<String> userList;
  final String roomId;
  final String timestamp;
  final String bookName;
  final String haverId;

  ChatRooms( this.lastMsg,  this.profileImg, this.userList, this.roomId,  this.timestamp, this.bookName, this.haverId);

  // factory ChatRooms.fromJson(Map<dynamic,dynamic> json){
  //   double parser(dynamic source){
  //     try{
  //       return dynamic.parse(source.toString());
  //     } on FormatException{
  //       return -1;
  //     }
  //   }
  //   return ChatRooms(lastMsg: parser(json['lastMsg']), profileImg: parser(json['lastMsg']), userList, roomId, timestamp, bookName)
  // }

  Map<String,dynamic> toMap(){
    return {
      'lastMsg':lastMsg,
      'profileImg':profileImg,
      'userList':userList,
      'roomId':roomId,
      'timestamp':timestamp,
      'bookName':bookName,
      'haverId':haverId,
    };
  }
}