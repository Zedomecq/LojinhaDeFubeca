import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../services/produto_banco.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProdutoModel> _listarProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarLista();
  }

  void _carregarLista() async {
    final produtos = await ProdutoBanco().listarProdutos();
    setState(() {
      _listarProdutos = produtos;
    });
  }

  void abrirFormulario(ProdutoModel? produto) {
    final nomeController = TextEditingController(text: produto?.nome ?? '');
    final descricaoController = TextEditingController(
      text: produto?.descricao ?? '',
    );
    final categoriaController = TextEditingController(
      text: produto?.categoria ?? '',
    );
    final valorController = TextEditingController(
      text: produto != null ? produto.valor.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            produto?.id == null ? "Cadastrar Produto" : "Editar Produto",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: "Descrição"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: "Categoria"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Valor (R\$)",
                    hintText: "0.00",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final double? valorConvertido = double.tryParse(
                  valorController.text.replaceAll(',', '.'),
                );

                if (nomeController.text.isEmpty || valorConvertido == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Preencha o nome e um valor válido!"),
                    ),
                  );
                  return;
                }

                final dadosProduto = ProdutoModel(
                  id: produto?.id,
                  nome: nomeController.text,
                  descricao: descricaoController.text,
                  categoria: categoriaController.text,
                  valor: valorConvertido,
                );

                _salvarDados(dadosProduto);
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _salvarDados(ProdutoModel produto) async {
    bool modoCadastro = produto.id == null;
    bool salvou = false;

    if (modoCadastro) {
      salvou = await ProdutoBanco().inserirProduto(produto);
    } else {
      salvou = await ProdutoBanco().atualizarProduto(produto);
    }

    if (salvou && mounted) {
      Navigator.of(context).pop();
      _carregarLista();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modoCadastro ? "Produto cadastrado!" : "Produto atualizado!",
          ),
        ),
      );
    }
  }

  void _abrirModalExclusao(ProdutoModel produto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Produto"),
          content: Text(
            "Deseja realmente excluir o produto \"${produto.nome}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deletarProduto(produto.id!);
                Navigator.pop(context);
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void deletarProduto(int id) async {
    bool deletou = await ProdutoBanco().deletarProduto(id);
    if (deletou && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto excluído com sucesso!")),
      );
      _carregarLista();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lojinha de Fubecas"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _listarProdutos.isEmpty
          ? const Center(child: Text("Nenhum produto cadastrado."))
          : ListView.builder(
              itemCount: _listarProdutos.length,
              itemBuilder: (context, index) {
                final item = _listarProdutos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.shopping_bag, color: Colors.white),
                    ),
                    title: Text(
                      item.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.descricao),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                item.categoria,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "R\$ ${item.valor.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => abrirFormulario(item),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () => _abrirModalExclusao(item),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
