import 'package:flutter/material.dart';

void main() => runApp(Jogo2048App());

class Jogo2048App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo 2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: Jogo2048Page(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Jogo2048Page extends StatefulWidget {
  @override
  _Jogo2048PageState createState() => _Jogo2048PageState();
}

class _Jogo2048PageState extends State<Jogo2048Page> {
  int movimentos = 0;
  int gridSize = 4;
  List<List<int>> tabuleiro = [];

  @override
  void initState() {
    super.initState();
    _inicializarTabuleiro();
  }

  void _inicializarTabuleiro() {
    tabuleiro = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    _adicionarNovaPeca(); // Coloca a peça inicial
  }

  void _mudarNivel(int tamanho) {
    setState(() {
      gridSize = tamanho;
      movimentos = 0;
      _inicializarTabuleiro();
    });
  }

  void _adicionarNovaPeca() {
    List<List<int>> vazias = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (tabuleiro[i][j] == 0) vazias.add([i, j]);
      }
    }

    if (vazias.isNotEmpty) {
      final pos = vazias[DateTime.now().millisecondsSinceEpoch % vazias.length];
      tabuleiro[pos[0]][pos[1]] = 1;
    }
  }

  void _mover(String direcao) {
    bool mudou = false;

    int dx = 0, dy = 0;
    int startRow = 0, endRow = gridSize, stepRow = 1;
    int startCol = 0, endCol = gridSize, stepCol = 1;

    switch (direcao) {
      case 'up':
        dx = -1;
        break;
      case 'down':
        dx = 1;
        startRow = gridSize - 1;
        endRow = -1;
        stepRow = -1;
        break;
      case 'left':
        dy = -1;
        break;
      case 'right':
        dy = 1;
        startCol = gridSize - 1;
        endCol = -1;
        stepCol = -1;
        break;
    }

    List<List<bool>> fundidos = List.generate(gridSize, (_) => List.filled(gridSize, false));

    List<List<int>> novoTabuleiro = List.generate(gridSize, (i) => List.from(tabuleiro[i]));

    for (int i = startRow; i != endRow; i += stepRow) {
      for (int j = startCol; j != endCol; j += stepCol) {
        int x = i, y = j;

        if (novoTabuleiro[x][y] == 0) continue;

        int valor = novoTabuleiro[x][y];
        int nx = x + dx;
        int ny = y + dy;

        while (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          if (novoTabuleiro[nx][ny] == 0) {
            // Move para célula vazia
            novoTabuleiro[nx][ny] = valor;
            novoTabuleiro[x][y] = 0;
            x = nx;
            y = ny;
            nx = x + dx;
            ny = y + dy;
            mudou = true;
          } else if (novoTabuleiro[nx][ny] == valor && !fundidos[nx][ny]) {
            // Funde com célula igual
            novoTabuleiro[nx][ny] *= 2;
            novoTabuleiro[x][y] = 0;
            fundidos[nx][ny] = true;
            mudou = true;
            break;
          } else {
            // Bloqueado por valor diferente
            break;
          }
        }
      }
    }

    if (mudou) {
      setState(() {
        tabuleiro = novoTabuleiro;
        movimentos++;
        _adicionarNovaPeca();
      });
    }
  }

  Widget _buildNivelButton(String texto, int tamanho) {
    return ElevatedButton(
      onPressed: () => _mudarNivel(tamanho),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange[300],
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(texto),
    );
  }

  Widget _buildSeta(IconData icone) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: IconButton(
        icon: Icon(icone, size: 36),
        onPressed: () {
          switch (icone) {
            case Icons.arrow_upward:
              _mover('up');
              break;
            case Icons.arrow_downward:
              _mover('down');
              break;
            case Icons.arrow_back:
              _mover('left');
              break;
            case Icons.arrow_forward:
              _mover('right');
              break;
          }
        },
        color: Colors.deepOrange[700],
        splashRadius: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Jogo 2048', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Botões de dificuldade
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNivelButton('Fácil', 4),
                SizedBox(width: 10),
                _buildNivelButton('Médio', 5),
                SizedBox(width: 10),
                _buildNivelButton('Difícil', 6),
              ],
            ),
            SizedBox(height: 20),

            // Contador de movimentos
            Text(
              'Movimentos: $movimentos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange[700],
              ),
            ),
            SizedBox(height: 20),

            // Grade do jogo
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: GridView.builder(
                    itemCount: gridSize * gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      int valor = tabuleiro[row][col];

                      return Container(
                        decoration: BoxDecoration(
                          color: valor > 0 ? Colors.deepOrange[300] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            valor > 0 ? '$valor' : '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Botões de movimento
            Column(
              children: [
                _buildSeta(Icons.arrow_upward),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSeta(Icons.arrow_back),
                    SizedBox(width: 20),
                    _buildSeta(Icons.arrow_forward),
                  ],
                ),
                _buildSeta(Icons.arrow_downward),
              ],
            ),
          ],
        ),
      ),
    );
  }
}