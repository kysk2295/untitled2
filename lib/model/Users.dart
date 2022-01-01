class Users{
  final String name;
  final String profileImg;
  final String email;
  final int registerBookCnt;
  final int borrowBookCnt;
  final int rentBookCnt;

  Users(this.name, this.profileImg, this.email, this.registerBookCnt, this.borrowBookCnt, this.rentBookCnt);

  Map<String,dynamic> toMap(){
    return{
      'name':name,
      'profileImg':profileImg,
      'email':email,
      'registerBookCnt':registerBookCnt,
      'borrowBookCnt':borrowBookCnt,
      'rentBookCnt':rentBookCnt
    };
  }


}