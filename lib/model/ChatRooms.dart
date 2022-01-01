class ChatRooms{
  final String lastMsg;
  final String profileImg;
  final List<String> userList;
  final String roomId;
  final String timestamp;
  final String bookName;

  ChatRooms(this.lastMsg, this.profileImg, this.userList, this.roomId, this.timestamp, this.bookName);

  Map<String,dynamic> toMap(){
    return {
      'lastMsg':lastMsg,
      'profileImg':profileImg,
      'userList':userList,
      'roomId':roomId,
      'timestamp':timestamp,
      'bookName':bookName
    };
  }
}