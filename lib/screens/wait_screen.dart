import 'package:flutter/material.dart';
import 'package:estudo/services/room.dart';
import 'package:estudo/screens/trivia_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;

  const WaitingRoomScreen({required this.roomId});

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final RoomService _roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _listenForRoomUpdates();
  }

  void _listenForRoomUpdates() {
    _roomService.getRoomStream(widget.roomId).listen((snapshot) {
      if (snapshot.exists) {
        final roomData = snapshot.data() as Map<String, dynamic>;
        if (roomData['competitors'].length == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TriviaScreen(
                isTimer: true,
                playerOnline: true,
                roomId: widget.roomId,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de espera'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Código da Sala",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.roomId,
                  style: GoogleFonts.robotoMono(fontSize: 22),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.roomId));
                  },
                  icon: const Icon(Icons.copy),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Aguardando jogadores...",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
