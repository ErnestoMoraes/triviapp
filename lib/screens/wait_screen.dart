import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:estudo/services/competitor.dart';
import 'package:estudo/services/room.dart';
import 'package:estudo/screens/trivia_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  const WaitingRoomScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

  @override
  WaitingRoomScreenState createState() => WaitingRoomScreenState();
}

class WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final RoomService _roomService = RoomService();
  List<CompetitorModel> competitors = [];
  final int maxCompetitors = 4;

  @override
  void initState() {
    super.initState();
    _listenForRoomUpdates();
  }

  void _listenForRoomUpdates() {
    _roomService.getRoomStream(widget.roomId).listen((snapshot) {
      if (snapshot.exists) {
        final roomData = snapshot.data() as Map<String, dynamic>;

        if (roomData['competitors'] != null) {
          setState(() {
            competitors = (roomData['competitors'] as Map<String, dynamic>)
                .values
                .map((competitor) => CompetitorModel.fromMap(competitor))
                .toList();
          });
        }

        if (roomData['competitors'].length == maxCompetitors ||
            roomData['status'] == 'gameing') {
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRoomCodeSection(),
                    const SizedBox(height: 40),
                    _buildRoomCapacityIndicator(),
                    const SizedBox(height: 40),
                    _buildCompetitorsSection(constraints),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (competitors.length >= 2) {
                          await _roomService.startGame(
                              widget.roomId, widget.userId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "A sala precisa de pelo menos 2 jogadores para começar."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Iniciar Jogo',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Seção do Código da Sala
  Widget _buildRoomCodeSection() {
    return Column(
      children: [
        Text(
          "Código da Sala",
          style: GoogleFonts.roboto(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              widget.roomId,
              style: GoogleFonts.robotoMono(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.roomId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Código copiado!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  // Indicador de capacidade da sala
  Widget _buildRoomCapacityIndicator() {
    return Text(
      "Jogadores: ${competitors.length}/$maxCompetitors",
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        fontSize: 18,
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Seção dos Competidores
  Widget _buildCompetitorsSection(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight * 0.5,
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dois competidores por linha
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: competitors.length,
        itemBuilder: (context, index) {
          final competitor = competitors[index];
          return _buildCompetitorCard(competitor);
        },
      ),
    );
  }

  // Card do Competidor
  Widget _buildCompetitorCard(CompetitorModel competitor) {
    String firstNameAndLastInitial =
        '${competitor.name.split(' ').first} ${competitor.name.split(' ').last}';
    return Card(
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto de Perfil
            CircleAvatar(
              radius: 40,
              backgroundImage: competitor.photoUrl.isNotEmpty
                  ? NetworkImage(competitor.photoUrl)
                  : null,
              child: competitor.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),

            // Nome do Competidor
            Flexible(
              child: Text(
                firstNameAndLastInitial,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
