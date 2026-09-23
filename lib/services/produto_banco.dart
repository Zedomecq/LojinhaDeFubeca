import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/produto_model.dart';

class ProdutoBanco {
  static final ProdutoBanco _instance = ProdutoBanco._internal();
  factory ProdutoBanco() => _instance;
  ProdutoBanco._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final caminhoBanco = await getDatabasesPath();
    final path = join(caminhoBanco, 'lojinha_fubecas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            descricao TEXT NOT NULL,
            categoria TEXT NOT NULL,
            valor REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<bool> inserirProduto(ProdutoModel produto) async {
    final db = await database;
    final id = await db.insert('produtos', produto.toJson()..remove('id'));
    return id > 0;
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    return maps.map((item) => ProdutoModel.fromJson(item)).toList();
  }

  Future<bool> atualizarProduto(ProdutoModel produto) async {
    final db = await database;
    final count = await db.update(
      'produtos',
      produto.toJson(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
    return count > 0;
  }

  Future<bool> deletarProduto(int id) async {
    final db = await database;
    final count = await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }
}
