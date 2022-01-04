class ChatMessage{

  String messageContent;
  String timestamp;
  String toUserUid;
  ChatMessage({required this.messageContent, required this.timestamp, required this.toUserUid});

  Map<String,dynamic> toMap(){
    return {
      'messageContent':messageContent,
      'timestamp':timestamp,
      'toUserUid':toUserUid,
    };
  }

}