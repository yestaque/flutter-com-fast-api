import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MyApp());

/* ================= APP ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loja de Bazar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const AppPrincipal(),
    );
  }
}

/* ================= MODELO ================= */

class Produto {
  final String nome;
  final double preco;
  final String imagem;

  Produto({required this.nome, required this.preco, required this.imagem});
}

final List<Produto> produtos = [
  Produto(nome: 'Caneca Decorada', preco: 25, imagem: 'https://picsum.photos/300?1'),
  Produto(nome: 'Vaso de Flor', preco: 45, imagem: 'https://picsum.photos/300?2'),
  Produto(nome: 'Almofada', preco: 60, imagem: 'https://picsum.photos/300?3'),
  Produto(nome: 'Quadro Decorativo', preco: 80, imagem: 'https://picsum.photos/300?4'),
];

List<Produto> carrinho = [];

/* ================= APP PRINCIPAL ================= */

class AppPrincipal extends StatefulWidget {
  const AppPrincipal({super.key});

  @override
  State<AppPrincipal> createState() => _AppPrincipalState();
}

class _AppPrincipalState extends State<AppPrincipal> {
  int index = 0;

  final telas = const [
    HomePage(),
    LojaPage(),
    CarrinhoPage(),
  ];

  final titulos = ['Home', 'Loja 🛍️', 'Carrinho 🛒'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulos[index])),
      body: telas[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Loja'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrinho'),
        ],
      ),
    );
  }
}

/* ================= HOME ================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ClockDateWidget(),
        Divider(height: 40),
        Text('Bem-vindo à Loja de Bazar!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
      ],
    );
  }
}

class ClockDateWidget extends StatefulWidget {
  const ClockDateWidget({super.key});

  @override
  State<ClockDateWidget> createState() => _ClockDateWidgetState();
}

class _ClockDateWidgetState extends State<ClockDateWidget> {
  late Timer timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${now.day}/${now.month}/${now.year}', style: const TextStyle(fontSize: 18)),
        Text('${now.hour}:${now.minute}:${now.second}', style: const TextStyle(fontSize: 28)),
      ],
    );
  }
}

/* ================= LOJA ================= */

class LojaPage extends StatelessWidget {
  const LojaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: produtos.length,
      itemBuilder: (_, i) {
        final p = produtos[i];
        return Card(
          child: Column(
            children: [
              Expanded(child: Image.network(p.imagem, fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('R\$ ${p.preco.toStringAsFixed(2)}'),
                    ElevatedButton(
                      onPressed: () {
                        carrinho.add(p);
                        ScaffoldMessenger.of(_).showSnackBar(
                          const SnackBar(content: Text('Adicionado ao carrinho')),
                        );
                      },
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================= CARRINHO ================= */

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  @override
  Widget build(BuildContext context) {
    if (carrinho.isEmpty) {
      return const Center(child: Text('Carrinho vazio'));
    }

    double total = carrinho.fold(0, (s, p) => s + p.preco);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: carrinho.length,
            itemBuilder: (_, i) {
              final p = carrinho[i];
              return ListTile(
                leading: Image.network(p.imagem, width: 50),
                title: Text(p.nome),
                subtitle: Text('R\$ ${p.preco.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => carrinho.removeAt(i)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Total: R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutPixPage()),
                  );
                },
                child: const Text('Pagar com PIX'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ================= CHECKOUT PIX ================= */

class CheckoutPixPage extends StatelessWidget {
  const CheckoutPixPage({super.key});

  @override
  Widget build(BuildContext context) {
    double total = carrinho.fold(0, (s, p) => s + p.preco);

    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento PIX')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.qr_code, size: 120),
            Text('Total: R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const SelectableText('email@seudominio.com'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                carrinho.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido finalizado!')),
                );
              },
              child: const Text('Finalizar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
