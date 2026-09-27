import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One everyday object the Random Hunt ("Cari Benda") mission can ask for.
///
/// [labels] are lower-cased classifier identifiers that count as finding it,
/// drawn from both engines: Apple Vision's `VNClassifyImageRequest` taxonomy
/// (iOS) and ML Kit's base image-labeling map (Android, lower-cased). Every
/// target here was checked against both label lists, so none of them is
/// impossible on either platform.
///
/// Deliberately excluded: anything reachable from bed (pillow, blanket), the
/// phone itself (it is holding the camera), and objects only one engine knows
/// (toothbrush, towel, fan). A target the phone cannot recognise is a mission
/// nobody can finish at 5am.
class HuntTarget {
  const HuntTarget({
    required this.id,
    required this.icon,
    required this.nameEn,
    required this.nameId,
    required this.labels,
  });

  final String id;
  final IconData icon;
  final String nameEn;
  final String nameId;
  final Set<String> labels;

  String name(String languageCode) => languageCode == 'id' ? nameId : nameEn;

  /// Highest confidence any of this target's labels received.
  double confidenceIn(Map<String, double> classifierLabels) {
    var best = 0.0;
    for (final entry in classifierLabels.entries) {
      if (labels.contains(entry.key.toLowerCase()) && entry.value > best) {
        best = entry.value;
      }
    }
    return best;
  }
}

abstract final class HuntTargets {
  /// Rerolls allowed per ringing session. Enough to skip an object you
  /// genuinely don't own, not enough to shop for the one on your nightstand.
  static const maxRerolls = 3;

  static const all = <HuntTarget>[
    HuntTarget(
      id: 'cup',
      icon: Icons.coffee_rounded,
      nameEn: 'Cup or mug',
      nameId: 'Gelas atau mug',
      labels: {'cup', 'mug'},
    ),
    HuntTarget(
      id: 'shoe',
      icon: Icons.directions_walk_rounded,
      nameEn: 'Shoes or sandals',
      nameId: 'Sepatu atau sandal',
      labels: {'shoes', 'shoe', 'sneaker', 'sneakers', 'sandal'},
    ),
    HuntTarget(
      id: 'helmet',
      icon: Icons.sports_motorsports_rounded,
      nameEn: 'Helmet',
      nameId: 'Helm',
      labels: {'helmet'},
    ),
    HuntTarget(
      id: 'bag',
      icon: Icons.backpack_rounded,
      nameEn: 'Bag or backpack',
      nameId: 'Tas',
      labels: {'bag', 'backpack'},
    ),
    HuntTarget(
      id: 'chair',
      icon: Icons.chair_alt_rounded,
      nameEn: 'Chair',
      nameId: 'Kursi',
      labels: {'chair'},
    ),
    HuntTarget(
      id: 'sofa',
      icon: Icons.weekend_rounded,
      nameEn: 'Sofa',
      nameId: 'Sofa',
      labels: {'sofa', 'couch'},
    ),
    HuntTarget(
      id: 'sink',
      icon: Icons.water_drop_rounded,
      nameEn: 'Sink',
      nameId: 'Wastafel',
      labels: {'sink', 'kitchen_sink'},
    ),
    HuntTarget(
      id: 'curtain',
      icon: Icons.curtains_rounded,
      nameEn: 'Curtain',
      nameId: 'Gorden',
      labels: {'curtain'},
    ),
    HuntTarget(
      id: 'tv',
      icon: Icons.tv_rounded,
      nameEn: 'TV',
      nameId: 'TV',
      labels: {'television'},
    ),
    HuntTarget(
      id: 'umbrella',
      icon: Icons.umbrella_rounded,
      nameEn: 'Umbrella',
      nameId: 'Payung',
      labels: {'umbrella'},
    ),
    HuntTarget(
      id: 'clock',
      icon: Icons.schedule_rounded,
      nameEn: 'Clock',
      nameId: 'Jam dinding',
      labels: {'clock'},
    ),
    HuntTarget(
      id: 'glasses',
      icon: Icons.visibility_rounded,
      nameEn: 'Glasses or sunglasses',
      nameId: 'Kacamata',
      labels: {'eyeglasses', 'glasses', 'sunglasses'},
    ),
    HuntTarget(
      id: 'hat',
      icon: Icons.person_rounded,
      nameEn: 'Hat or cap',
      nameId: 'Topi',
      labels: {'hat'},
    ),
    HuntTarget(
      id: 'jacket',
      icon: Icons.checkroom_rounded,
      nameEn: 'Jacket',
      nameId: 'Jaket',
      labels: {'jacket'},
    ),
    HuntTarget(
      id: 'plant',
      icon: Icons.local_florist_rounded,
      nameEn: 'Plant or flower',
      nameId: 'Tanaman atau bunga',
      labels: {'plant', 'flower'},
    ),
    HuntTarget(
      id: 'tableware',
      icon: Icons.restaurant_rounded,
      nameEn: 'Plate, bowl or spoon',
      nameId: 'Piring, mangkuk atau sendok',
      labels: {
        'plate',
        'bowl',
        'spoon',
        'fork',
        'utensil',
        'tableware',
        'cutlery',
      },
    ),
    HuntTarget(
      id: 'laptop',
      icon: Icons.laptop_rounded,
      nameEn: 'Laptop or computer',
      nameId: 'Laptop atau komputer',
      labels: {'laptop', 'computer', 'computer_keyboard'},
    ),
  ];

  static HuntTarget? byId(String id) {
    for (final target in all) {
      if (target.id == id) return target;
    }
    return null;
  }

  /// A random target, never one of [exclude] while alternatives remain.
  static HuntTarget pick(math.Random random, {Set<String> exclude = const {}}) {
    final pool = all.where((t) => !exclude.contains(t.id)).toList();
    final source = pool.isEmpty ? all : pool;
    return source[random.nextInt(source.length)];
  }
}
