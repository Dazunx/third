import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../util/size.dart';
import '../mail.dart';
import '../mail_content/show_mail.dart';
import '../mail_content/temporaryStorage_modal.dart';
import 'mail_card.dart';

class MailList extends StatefulWidget {
  MailList(this.title, {Key? key}) : super(key: key);
  String? title;

  @override
  State<MailList> createState() => _MailListState();
}

class _MailListState extends State<MailList> {
  final user = FirebaseAuth.instance.currentUser;

  late QuerySnapshot querySnapshot;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('mail').snapshots(),
      // FirebaseFirestore.instance.collection('mail').orderBy('time', descending: true).snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        //아직 데이터가 다 가져와지지 않았다면 파란색 동그라미가 보여짐
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(), //로딩되는 동그라미 보여주기
          );
        }

        List<Mail> mailDocs = [];

        //print(widget.title);

        if (snapshot.hasData) {
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            var one = snapshot.data!.docs[i];

            //'메일을 보낸 사람이나 받은 사람 중에 현재 사용자가 해당한다면' mailDocs list에 담아준다.
            if (one.get('writer') == user!.email ||
                one.get('recipient') == user!.email) {

              Timestamp t = one.get('time');//파이어베이스에서 time은 메일이 보내진 시간을 의미하는데, Timestamp 형태로 저장되기 때문에 형변환이 필요함
              print(one.get('time'));//console에서 보기
              String time = DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch).toString().split(" ")[0];
              //2022-07-04 10:45:45.473999 이런 형태라서, ' '를 기준으로 쪼개서 앞에 날짜만 가져옵니다.
              print(DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch).toString());
              print(time);
              time = time.replaceAll("-", ".");

              //Mail 생성자를 이용해 데이터를 담은 객체를 만들고 list에 추가 시켜준다.
              Mail mail = Mail(one.id,one.get('title'), one.get('content'), one.get('writer'), one.get('recipient'), time, one.get('read'), one.get('sent'));

              if (widget.title == "보낸 편지함") {
                if (one.get('writer') == user!.email) {
                  //trick: 내가 보낸 편지는 내가 열어볼때 read 값이 false이어도 이미 읽은 것으로 보여주기 위한 -> 생성자에 값을 다르게 넣어줌
                  Mail mymail = Mail(one.id,one.get('title'), one.get('content'), one.get('writer'), one.get('recipient'), time, true, one.get('sent'));
                  mailDocs.add(mymail);
                }
              }
              else if (widget.title == "받은 편지함") {
                if (one.get('recipient') == user!.email) {
                  mailDocs.add(mail);
                }
              }
              else if (widget.title == "임시 저장") {
                if (one.get('writer') == user!.email &&
                    one.get('sent') == false) {
                  mailDocs.add(mail);
                }
              }
              else if (widget.title == "모든 메일") {
                mailDocs.add(mail);
              }
              else {}

            }
          }
        }
        //final mailDocs = snapshot.data!.docs;//docs에 접근

        return ListView.builder(
            itemCount: mailDocs.length,
            itemBuilder: (context, index) {

              //사용자가 클릭하면 반응함.
              // 추가하고 flutter pub add flutter_slidable
              return /*Slidable(
                //key: const ValueKey(0),
                //left, top
                startActionPane: widget.title == '받은 편지함' ?
                ActionPane(
                  motion: const ScrollMotion(),

                  //dismissible: DismissiblePane(onDismissed: (){},),
                  children: [
                    SlidableAction(
                      onPressed: (context){
                        FirebaseFirestore.instance.collection('mail').doc(mailDocs[index].mail_id).update({'read':false});
                      },
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      icon: CupertinoIcons.envelope_badge_fill,
                      label:'읽지 않음',


                    )
                  ],

                ): null,

                //right, bottom
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                        onPressed: (context){
                          //삭제의 경우 파이어베이스 설계를 잘못함. user에게만 없어져야 하는데 보낸이와 받은이 모두 없어지기 때문
                          FirebaseFirestore.instance.collection('mail').doc(mailDocs[index].mail_id).delete();
                        },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: CupertinoIcons.delete,
                      label:'휴지통',
                    )
                  ],
                ),

                child: */GestureDetector(
                onTap: () {
                  /*
                    //받은 사람이 메일을 읽으려고 onTap을 하면 파이어베이스의 mail - read 부분을 true로 update 해주어야 함
                    if(mailDocs[index].recipient == user?.email){
                      FirebaseFirestore.instance.collection('mail').doc(mailDocs[index].mail_id).update({'read':true});
                    }
                   */
                  widget.title == "임시 저장" ?
                  showModalBottomSheet( //reference : https://api.flutter.dev/flutter/material/showModalBottomSheet.html
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      context: context,
                      builder: (context) => Container(
                        height: getScreenHeight(context)*0.9,
                        child: ShowTemporaryStorage(mailDocs[index]),
                      )
                  ) :
                  Get.to(ShowMail(mailDocs[index]));
                },                //itemCount 갯수만큼, MailCard 를 가져와서 보여줌.
                child: MailCard(mailDocs[index]),
                //),
              );
            }
        );
      },

    );
  }
}