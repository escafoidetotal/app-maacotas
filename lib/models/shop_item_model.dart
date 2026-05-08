import 'package:flutter/material.dart';

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String category; // 'hat', 'collar', 'outfit', 'skin', 'theme'
  final IconData icon;
  final Color color;
  bool isOwned;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.category,
    required this.icon,
    required this.color,
    this.isOwned = false,
  });

  static List<ShopItemModel> get defaultItems => [
    ShopItemModel(
      id: 'hat_party',
      name: 'Chapéu de Festa',
      description: 'Um chapéu colorido para celebrar!',
      cost: 50,
      category: 'hat',
      icon: Icons.celebration,
      color: const Color(0xFFFF6B35),
    ),
    ShopItemModel(
      id: 'hat_cowboy',
      name: 'Chapéu de Cowboy',
      description: 'Para o pet mais estiloso do oeste!',
      cost: 75,
      category: 'hat',
      icon: Icons.agriculture,
      color: const Color(0xFF8B4513),
    ),
    ShopItemModel(
      id: 'hat_crown',
      name: 'Coroa Real',
      description: 'Para o rei ou rainha dos pets!',
      cost: 150,
      category: 'hat',
      icon: Icons.star,
      color: const Color(0xFFFFD700),
    ),
    ShopItemModel(
      id: 'collar_bow',
      name: 'Laço Elegante',
      description: 'Um laço charmos para o seu pet.',
      cost: 40,
      category: 'collar',
      icon: Icons.favorite,
      color: const Color(0xFFFF69B4),
    ),
    ShopItemModel(
      id: 'collar_diamond',
      name: 'Coleira Diamante',
      description: 'Coleira de luxo com pedras brilhantes.',
      cost: 200,
      category: 'collar',
      icon: Icons.diamond,
      color: const Color(0xFF4ECDC4),
    ),
    ShopItemModel(
      id: 'collar_star',
      name: 'Coleira Estrela',
      description: 'Brilhe como uma estrela!',
      cost: 80,
      category: 'collar',
      icon: Icons.star_border,
      color: const Color(0xFFFFE66D),
    ),
    ShopItemModel(
      id: 'outfit_superhero',
      name: 'Super-herói',
      description: 'Capa e tudo! Seu pet vai salvar o dia.',
      cost: 120,
      category: 'outfit',
      icon: Icons.bolt,
      color: const Color(0xFF3498DB),
    ),
    ShopItemModel(
      id: 'outfit_astronaut',
      name: 'Astronauta',
      description: 'Para explorar novos mundos!',
      cost: 180,
      category: 'outfit',
      icon: Icons.rocket_launch,
      color: const Color(0xFF9B59B6),
    ),
    ShopItemModel(
      id: 'outfit_chef',
      name: 'Chef de Cozinha',
      description: 'O melhor cozinheiro do bairro!',
      cost: 100,
      category: 'outfit',
      icon: Icons.restaurant,
      color: const Color(0xFF2ECC71),
    ),
    ShopItemModel(
      id: 'theme_ocean',
      name: 'Tema Oceano',
      description: 'Cores do mar para o app.',
      cost: 300,
      category: 'theme',
      icon: Icons.waves,
      color: const Color(0xFF1A85C8),
    ),
    ShopItemModel(
      id: 'theme_forest',
      name: 'Tema Floresta',
      description: 'Tons verdes e naturais.',
      cost: 300,
      category: 'theme',
      icon: Icons.forest,
      color: const Color(0xFF27AE60),
    ),
    ShopItemModel(
      id: 'theme_sunset',
      name: 'Tema Pôr do Sol',
      description: 'Cores quentes e aconchegantes.',
      cost: 300,
      category: 'theme',
      icon: Icons.wb_twilight,
      color: const Color(0xFFE74C3C),
    ),
    ShopItemModel(
      id: 'skin_golden',
      name: 'Skin Dourado',
      description: 'Avatar dourado brilhante.',
      cost: 250,
      category: 'skin',
      icon: Icons.pets,
      color: const Color(0xFFD4A017),
    ),
    ShopItemModel(
      id: 'skin_rainbow',
      name: 'Skin Arco-íris',
      description: 'Todas as cores do arco-íris!',
      cost: 500,
      category: 'skin',
      icon: Icons.color_lens,
      color: const Color(0xFFE91E63),
    ),
  ];
}
