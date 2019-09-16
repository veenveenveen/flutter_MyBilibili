import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/material_controls.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_MyBilibili/icons/bilibili_icons.dart';
import 'package:flutter_MyBilibili/model/VideoItem.dart';
import 'package:flutter_MyBilibili/model/VideoItemFromJson.dart';
import 'package:flutter_MyBilibili/pages/home/ReviewsPage.dart';
import 'package:flutter_MyBilibili/pages/home/video_detail_page.dart';
import 'package:flutter_MyBilibili/util/GetUtilBilibili.dart';
import 'package:flutter_MyBilibili/util/video_api.dart';
import 'package:flutter_MyBilibili/views/my_chewie_custom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class VideoPlayPage extends StatefulWidget {
  @override
  final VideoItem videoitem; //视频基本信息，av号封面
  VideoPlayPage(this.videoitem);
  _VideoPlayPageState createState() => _VideoPlayPageState(videoitem);
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  var _videoplayscaffoldkey = new GlobalKey<ScaffoldState>(); //key的用法
  final VideoItem videoitem;
  VideoItemFromJson videoItemFromJson; //视频详细信息，介绍等
  TabController _tabController =
      TabController(length: 2, vsync: AnimatedListState());
  VideoPlayerController _videoController;
  ChewieController _chewieController;
  bool _getvideodetailisok = false;
  bool isclickcover = false;
  bool _isHideTitle = true;
  _VideoPlayPageState(this.videoitem);
  @override
  void initState() {
    //设置封面滚动监听，隐藏标题
    // _nestedScrollViewController.addListener(() {
    //   if (_nestedScrollViewController.offset > 110 && _isHideTitle == true) {
    //     setState(() {
    //       _isHideTitle = false;
    //     });
    //   } else if (_nestedScrollViewController.offset <= 110 &&
    //       _isHideTitle == false) {
    //     setState(() {
    //       _isHideTitle = true;
    //     });
    //   }
    // });
    // _loadHtmlFromAssets();
    getDetail();
    setVideoUrl();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    if(_chewieController !=null) _chewieController.dispose();
    if(_videoController !=null) _videoController.dispose();
  }

  void getDetail() async {
    videoItemFromJson =
        await GetUtilBilibili.getVideoDetailByAid(videoitem.aid);
    if (videoItemFromJson != null) {
      _getvideodetailisok = true;
      print("getDetailok");
    }
    if (this.mounted) {
      setState(() {});
    }
  }
  //显示提示
  void showSnackBar(String message) {
    var snackBar = SnackBar(content: Text(message));
    _videoplayscaffoldkey.currentState.showSnackBar(snackBar);
  }

  void setVideoUrl({int page}) async {
    var url = await VideoApi.getVideoPlayUrl(videoitem.aid, page: page);
    print("url: " + url);
    if (url == null) {
      Fluttertoast.showToast(msg: "获取视频播放地址失败");
      return;
    }
    if (url is String) {
      _videoController = VideoPlayerController.network(
        url,
      )..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              placeholder: Center(
                child: Text("正在缓冲",style: TextStyle(color: Colors.white30),),
              ),
              autoPlay: true,
              allowedScreenSleep: false,
              customControls: MyChewieMaterialControls()
            );
          });
        });
    }
  }

  void setVideoUrlTemp() async {
    _videoController = VideoPlayerController.network(
      "http://upos-hz-mirrorakam.akamaized.net/upgcxcode/80/50/67185080/67185080-1-6.mp4?e=ig8euxZM2rNcNbRBhwdVhoM17WdVhwdEto8g5X10ugNcXBB_&deadline=1568605530&dynamic=1&gen=playurl&oi=1886944469&os=akam&platform=html5&rate=150000&trid=615451b499864313ab4585fee55a1490&uipk=5&uipv=5&um_deadline=1568605530&um_sign=be0bcb66049aa20c832c107e2637dc7f&upsig=691c2f0634c0abdca873aae2df85ff3e&uparams=e,deadline,dynamic,gen,oi,os,platform,rate,trid,uipk,uipv,um_deadline,um_sign&hdnts=exp=1568605530~hmac=b8aa313bbd254137d71781bcd853cd811708675de85a324b3bfca98a863963d2&mid=0",
    )..initialize().then((_) {
        if (this.mounted) {
          setState(() {});
        }
      });
  }

  // _loadHtmlFromAssets() async {
  //   String fileText = await rootBundle.loadString('assets/html/hello.html');
  //   flutterWebviewPlugin.reloadUrl( Uri.dataFromString(
  //       fileText,
  //       mimeType: 'text/html',
  //       encoding: Encoding.getByName('utf-8')
  //   ).toString(),
  //   headers: {"Cookie":"buvid3=5410244B-513B-4AB8-98AC-0B6F466E36A3190966infoc"},
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _videoplayscaffoldkey,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.width * 10 / 16),
        child: AppBar(
          elevation: 1,
          centerTitle: true,
          automaticallyImplyLeading: true,
          flexibleSpace: GestureDetector(
            onDoubleTap: () {
              _videoController.value.isPlaying
                  ? _chewieController.pause()
                  : _chewieController.play();
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 44),
              color: Colors.black,
              width: double.infinity,
              child: _chewieController != null
                  ? Chewie(
                      controller: _chewieController,
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: _showCheckDialog,
            )
          ],
          bottom: GetPreferredSizeWidget(
            Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.pinkAccent,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.pinkAccent,
                      tabs: <Widget>[
                        Tab(
                          text: "简介",
                        ),
                        Tab(
                          text: "评论",
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(right: 40),
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            BIcon.danmu_off,
                            color: Colors.grey[600],
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _getvideodetailisok
          ? TabBarView(
              controller: _tabController,
              children: <Widget>[
                VideoDetailPage(videoItemFromJson, videoitem),
                ReviewsPage(
                  videoitem.aid,
                ),
              ],
            )
          : Center(child: Text("正在加载")),
    );
  }

  _showCheckDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(15),
        content: Text(
          '是否保存封面?',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("确定"),
            onPressed: () async {
              Navigator.pop(context);
              await _saveCover(videoitem.cover);
            },
          ),
        ],
      ),
    );
  }

  _saveCover(String url) async {
    Fluttertoast.showToast(msg: "正在保存");
    //先检查权限
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.granted) {
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
      Fluttertoast.showToast(msg: "保存成功 路径" + result);
    } else {
      Fluttertoast.showToast(msg: "申请权限失败");
    }
  }
}

openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "no";
  }
}

class GetPreferredSizeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return child;
  }

  GetPreferredSizeWidget(
    this.child, {
    Key key,
  }) : super(key: key);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => getSize();

  Size getSize() {
    return new Size(44.0, 44.0);
  }
}