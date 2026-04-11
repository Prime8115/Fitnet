// lib/data/workout_data.dart
// Complete 84-day workout data starting April 10, 2025

class Exercise {
  final String name;
  final String? note;
  final String sets;
  final String muscleGroup;

  const Exercise({
    required this.name,
    this.note,
    required this.sets,
    required this.muscleGroup,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'note': note,
    'sets': sets,
    'muscleGroup': muscleGroup,
  };

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
    name: j['name'],
    note: j['note'],
    sets: j['sets'],
    muscleGroup: j['muscleGroup'],
  );
}

class WorkoutSection {
  final String name;
  final List<Exercise> exercises;

  const WorkoutSection({required this.name, required this.exercises});
}

class WorkoutDay {
  final int dayNumber;        // 1-84 (or beyond for extended plans)
  final DateTime date;
  final WorkoutType type;
  final String label;
  final String focus;
  final String warmup;
  final List<WorkoutSection> sections;
  final List<Exercise> coreFinisher;
  final int weekNumber;
  final int phase;            // 1, 2, or 3
  final String phaseLabel;
  final bool isDeload;

  const WorkoutDay({
    required this.dayNumber,
    required this.date,
    required this.type,
    required this.label,
    required this.focus,
    required this.warmup,
    required this.sections,
    required this.coreFinisher,
    required this.weekNumber,
    required this.phase,
    required this.phaseLabel,
    required this.isDeload,
  });
}

enum WorkoutType { push, pull, legs, combat, fullBody, rest, deload }

extension WorkoutTypeExt on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.push: return 'Push Day';
      case WorkoutType.pull: return 'Pull Day';
      case WorkoutType.legs: return 'Leg Day';
      case WorkoutType.combat: return 'Combat & Core';
      case WorkoutType.fullBody: return 'Full Body Power';
      case WorkoutType.rest: return 'Active Rest';
      case WorkoutType.deload: return 'Deload Week';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutType.push: return '🔴';
      case WorkoutType.pull: return '🟠';
      case WorkoutType.legs: return '🟡';
      case WorkoutType.combat: return '🔵';
      case WorkoutType.fullBody: return '🟣';
      case WorkoutType.rest: return '⚪';
      case WorkoutType.deload: return '🩷';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE WORKOUTS — reused each week, upgraded per phase
// ─────────────────────────────────────────────────────────────────────────────

WorkoutSection _sec(String name, List<Exercise> exs) =>
    WorkoutSection(name: name, exercises: exs);

Exercise _ex(String name, String sets, String muscle, [String? note]) =>
    Exercise(name: name, sets: sets, muscleGroup: muscle, note: note);

// ── PHASE 1 WORKOUTS ────────────────────────────────────────────────────────

final List<WorkoutSection> _p1PushSections = [
  _sec('UPPER CHEST', [_ex('Incline Barbell Press', '4×8–10', 'Upper Pectorals')]),
  _sec('MID / LOWER CHEST', [
    _ex('Flat Dumbbell Press', '3×10', 'Mid Pectorals'),
    _ex('Decline Push-Ups', '3×15', 'Lower Pectorals'),
  ]),
  _sec('ANTERIOR DELTOID', [_ex('Overhead Barbell Press', '3×10', 'Front Delt')]),
  _sec('LATERAL DELTOID', [_ex('Dumbbell Lateral Raise', '3×15', 'Side Delt')]),
  _sec('POSTERIOR DELT / ROTATOR CUFF', [
    _ex('Face Pull (Cable)', '3×15', 'Rear Delt / Rotator Cuff', 'Protects shoulder joint'),
  ]),
  _sec('TRICEPS (ALL 3 HEADS)', [
    _ex('Tricep Dips', '3×12', 'Triceps'),
    _ex('Overhead DB Extension', '3×12', 'Triceps Long Head', 'Long head focus'),
    _ex('Rope Pushdown', '3×15', 'Triceps Lateral Head', 'Lateral head'),
  ]),
  _sec('SERRATUS ANTERIOR', [_ex('Serratus Cable Punch', '2×15', 'Serratus Anterior')]),
];
final List<Exercise> _p1PushCore = [
  _ex('Plank (anti-rotation)', '3×45s', 'Transverse Abdominis'),
  _ex('Hanging Knee Raise', '3×12', 'Lower Rectus Abdominis'),
  _ex('Cable Crunch', '3×15', 'Rectus Abdominis'),
];

final List<WorkoutSection> _p1PullSections = [
  _sec('ERECTOR SPINAE / LOWER BACK', [
    _ex('Deadlift (Conventional)', '4×6–8', 'Erector Spinae', 'Hinge — brace core'),
  ]),
  _sec('LATISSIMUS DORSI', [
    _ex('Pull-Ups / Lat Pulldown', '4×8–10', 'Latissimus Dorsi'),
    _ex('Straight-Arm Cable Pulldown', '3×12', 'Lats'),
  ]),
  _sec('RHOMBOIDS / MID TRAPEZIUS', [
    _ex('Barbell Bent-Over Row', '3×10', 'Rhomboids / Mid Traps'),
    _ex('Seated Cable Row (wide grip)', '3×12', 'Mid Back'),
  ]),
  _sec('UPPER TRAPEZIUS', [_ex('DB Shrug', '3×15', 'Upper Trapezius')]),
  _sec('TERES MAJOR / POSTERIOR DELT', [_ex('Reverse Pec Deck', '3×15', 'Teres Major / Rear Delt')]),
  _sec('BICEPS', [_ex('Barbell Curl', '3×12', 'Biceps Brachii')]),
  _sec('BRACHIALIS / FOREARMS', [
    _ex('Hammer Curl', '3×12', 'Brachialis / Brachioradialis', 'Brachialis + brachioradialis'),
    _ex('Wrist Curl + Reverse Wrist Curl', '2×15', 'Forearm Flexors & Extensors'),
  ]),
];
final List<Exercise> _p1PullCore = [
  _ex('Dead Bug (TVA)', '3×10/side', 'Transverse Abdominis'),
  _ex('Russian Twist', '3×20', 'Obliques'),
  _ex('Hollow Body Hold', '3×30s', 'Deep Core'),
];

final List<WorkoutSection> _p1CombatSections = [
  _sec('SHOULDER / ROTATORS (PUNCHING)', [
    _ex('Shadow Boxing — Jab-Cross-Hook', '4×2 min', 'Shoulders / Core Rotators', 'Torso rotation, deltoids, core'),
  ]),
  _sec('HIP FLEXORS / GLUTES / CALVES (KICKING)', [
    _ex('Kickboxing — Front Kick + Round Kick', '4×2 min', 'Hip Flexors / Glutes / Calves', 'Alternate legs each round'),
  ]),
  _sec('FULL KINETIC CHAIN (SANDBAG)', [
    _ex('Sandbag Clean & Press', '4×10', 'Full Body', 'Legs→hips→back→shoulders'),
    _ex('Sandbag Shouldering', '3×8/side', 'Full Body', 'Alternate shoulders'),
    _ex('Sandbag Bear Hug Squat', '3×12', 'Quads / Glutes / Core'),
    _ex('Sandbag Carry (40m)', '4 rounds', 'Full Body'),
  ]),
  _sec('NECK STABILITY', [
    _ex('Neck Isometric 4-Way', '2×each 10s', 'Neck / SCM', 'Forward, back, each side'),
  ]),
];
final List<Exercise> _p1CombatCore = [
  _ex('Ab Wheel Rollout', '3×10', 'Rectus Abdominis / Deep Core'),
  _ex('Side Plank', '2×30s/side', 'Obliques'),
  _ex('Mountain Climbers', '3×20', 'Core / Hip Flexors'),
];

final List<WorkoutSection> _p1LegsSections = [
  _sec('QUADRICEPS (ALL 4 HEADS)', [
    _ex('Barbell Back Squat', '4×8', 'Quadriceps', 'Main quad mass builder'),
    _ex('Leg Press', '3×12', 'Quadriceps'),
    _ex('Leg Extension (VMO)', '3×15', 'VMO / Quads'),
  ]),
  _sec('HAMSTRINGS (ALL 3 HEADS)', [
    _ex('Romanian Deadlift', '3×10', 'Hamstrings'),
    _ex('Leg Curl (Lying)', '3×12', 'Hamstrings'),
  ]),
  _sec('GLUTES (MAX, MED, MIN)', [
    _ex('Walking Lunges', '3×12/leg', 'Glutes / Quads'),
    _ex('Hip Thrust (Barbell)', '3×12', 'Glutes Max'),
  ]),
  _sec('ADDUCTORS / ABDUCTORS', [
    _ex('Sumo Squat', '3×12', 'Adductors / Inner Thigh'),
    _ex('Cable Hip Abduction', '2×15/side', 'Glutes Med / Abductors'),
  ]),
  _sec('CALVES (GASTROCNEMIUS + SOLEUS)', [
    _ex('Standing Calf Raise', '4×20', 'Gastrocnemius', 'Straight leg — gastrocnemius'),
    _ex('Seated Calf Raise', '3×20', 'Soleus', 'Bent knee — soleus'),
  ]),
];
final List<Exercise> _p1LegsCore = [
  _ex('Hanging Leg Raise', '3×12', 'Lower Abs / Hip Flexors'),
  _ex('Plank Hip Dip', '3×15/side', 'Obliques / Core'),
];

final List<WorkoutSection> _p1FullSections = [
  _sec('FULL POSTERIOR CHAIN', [
    _ex('Power Clean', '4×5', 'Full Body', 'Calves→glutes→back→traps→shoulders'),
  ]),
  _sec('BACK / LATS / BICEPS', [_ex('Weighted Pull-Up', '4×6–8', 'Lats / Back / Biceps')]),
  _sec('CHEST / SHOULDERS / TRICEPS', [_ex('Dumbbell Floor Press', '3×10', 'Chest / Shoulders / Triceps')]),
  _sec('HAMSTRINGS / GLUTES / BALANCE', [
    _ex('Single-Leg Romanian Deadlift', '3×8/side', 'Hamstrings / Glutes / Balance'),
  ]),
  _sec('UPPER BACK / ROTATOR CUFF', [
    _ex('DB Rear Delt Row', '3×12', 'Rear Delt / Upper Back'),
    _ex('External Rotation (cable)', '2×15/side', 'Infraspinatus / Teres Minor', 'Rotator cuff health'),
  ]),
  _sec('GRIP / FOREARMS', [
    _ex("Farmer's Carry (40m)", '4 rounds', 'Forearms / Grip / Core'),
  ]),
];
final List<Exercise> _p1FullCore = [
  _ex('Dragon Flag', '3×6', 'Full Core'),
  _ex('Pallof Press', '3×12/side', 'Anti-Rotation Core'),
  _ex('V-Sit', '3×15', 'Hip Flexors / Abs'),
];

final List<WorkoutSection> _p1SatCombatSections = [
  _sec('FULL BODY STAMINA', [
    _ex('Shadow Boxing — Full Combos', '5×3 min', 'Full Body / Cardiovascular', 'Jab-cross-hook-uppercut-body shot'),
    _ex('Kickboxing — High Kick + Knee Strike', '4×2 min', 'Legs / Core / Shoulders'),
  ]),
  _sec('POSTERIOR CHAIN + SHOULDERS', [
    _ex('Sandbag Slam', '4×10', 'Lats / Core / Glutes'),
    _ex('Sandbag Ground & Pound', '3×30s', 'Shoulders / Core'),
    _ex('Sandbag Squat to Shoulder Press', '3×10', 'Legs / Shoulders'),
    _ex('Burpee + Shadow Combo', '3×10', 'Full Body'),
  ]),
];

final List<WorkoutSection> _restSections = [
  _sec('RECOVERY', [
    _ex('Light Walk or Easy Swim', '30 min', 'Active Recovery'),
    _ex('Full-Body Yoga / Static Stretch', '25 min', 'Flexibility'),
    _ex('Foam Roll — All Major Groups', '15 min', 'Recovery'),
    _ex('Breathwork / Meditation', '10 min', 'Mental Recovery'),
  ]),
];

// ── PHASE 2 WORKOUTS ────────────────────────────────────────────────────────

final List<WorkoutSection> _p2PushSections = [
  _sec('MID + UPPER CHEST (SUPERSET)', [
    _ex('★ Incline Barbell Press + Incline DB Fly', '4×8+12', 'Upper / Mid Pectorals', 'No rest between pair'),
  ]),
  _sec('LOWER CHEST', [
    _ex('★ Decline DB Press + Cable Low-High Fly', '3×10+12', 'Lower Pectorals'),
  ]),
  _sec('ALL 3 DELTOIDS', [
    _ex('Arnold Press', '4×10', 'All 3 Deltoid Heads'),
    _ex('★ Lateral Raise + Front Raise', '3×15+12', 'Lateral / Anterior Delt'),
  ]),
  _sec('ROTATOR CUFF', [_ex('Band External Rotation', '3×15/side', 'Rotator Cuff')]),
  _sec('TRICEPS — ALL HEADS', [
    _ex('Close-Grip Bench Press', '3×10', 'Triceps Medial Head'),
    _ex('★ OH Tricep Ext + Rope Pushdown', '3×12+15', 'Triceps Long + Lateral Head'),
  ]),
  _sec('SERRATUS ANTERIOR', [_ex('Push-Up Plus (protraction)', '2×15', 'Serratus Anterior')]),
];
final List<Exercise> _p2PushCore = [
  _ex('Ab Wheel Rollout', '4×12', 'Deep Core'),
  _ex('Decline Sit-Up', '3×20', 'Rectus Abdominis'),
  _ex('Plank Shoulder Tap', '3×10/side', 'Anti-Rotation Core'),
  _ex('Hanging Leg Raise', '3×15', 'Lower Abs'),
];

final List<WorkoutSection> _p2PullSections = [
  _sec('LOWER BACK / ERECTORS', [
    _ex('Rack Pull (Heavy)', '5×5', 'Erector Spinae', 'Knee-height start — heavy loading'),
  ]),
  _sec('LATS WIDTH', [
    _ex('★ Wide-Grip Pull-Ups + Straight-Arm PD', '4×8+12', 'Latissimus Dorsi'),
  ]),
  _sec('BACK THICKNESS', [
    _ex('T-Bar Row', '4×8', 'Mid Back / Rhomboids'),
    _ex('★ Seated Cable Row + Face Pull', '3×12+15', 'Rhomboids / Rear Delt'),
  ]),
  _sec('UPPER TRAPS', [_ex('Barbell Shrug + Neck Stretch', '4×15', 'Upper Trapezius / Levator Scapulae')]),
  _sec('BICEPS', [
    _ex('★ Barbell Curl + Reverse Curl', '3×10+10', 'Biceps / Brachioradialis'),
    _ex('Incline DB Curl', '3×12', 'Biceps Long Head'),
  ]),
  _sec('FOREARMS', [
    _ex('★ Wrist Curl + Reverse Wrist Curl', '3×15+15', 'Forearm Flexors & Extensors'),
    _ex('Plate Pinch Hold', '3×30s', 'Grip / Forearm Extensors'),
  ]),
];
final List<Exercise> _p2PullCore = [
  _ex('Dragon Flag', '3×6', 'Full Core'),
  _ex('Windshield Wipers', '3×10', 'Obliques'),
  _ex('Hollow Rock', '3×20s', 'Deep Core'),
];

final List<WorkoutSection> _p2CombatSections = [
  _sec('SHOULDERS / CORE ROTATORS', [
    _ex('Shadow Boxing — Slip & Counter', '6×3 min', 'Shoulders / Spinal Rotators', 'Bob-weave, multi-punch combos'),
  ]),
  _sec('HIP FLEXORS / GLUTES (KICKING HIIT)', [
    _ex('Kickboxing HIIT', '8 rounds', 'Hip Flexors / Glutes / Quads', '40s max intensity / 20s rest'),
  ]),
  _sec('FULL BODY — SANDBAG COMPLEX', [
    _ex('Sandbag Complex (no rest)', '5×6', 'Full Body', 'Clean→Press→Squat→Slam per rep'),
    _ex('Sandbag Rotational Throw', '4×8/side', 'Obliques / Hip Rotators'),
    _ex('Sandbag Get-Up (Turkish-style)', '3×5/side', 'Full Body / Core'),
  ]),
  _sec('NECK / SCM', [
    _ex('Neck Isometric 4-Way + Lateral Flexion', '3×10s', 'Neck / SCM'),
  ]),
];
final List<Exercise> _p2CombatCore = [
  _ex('Med Ball Slam', '4×10', 'Core / Full Body'),
  _ex('Twisting Crunch', '3×20', 'Obliques'),
  _ex('Plank Punch (anti-rotation)', '3×15/side', 'Anti-Rotation Core'),
];

final List<WorkoutSection> _p2LegsSections = [
  _sec('QUADRICEPS (DEEP)', [
    _ex('Front Squat', '4×8', 'Quadriceps / Core'),
    _ex('★ Hack Squat + Leg Extension', '3×12+15', 'Quads / VMO'),
  ]),
  _sec('HAMSTRINGS', [
    _ex('★ Romanian DL + Lying Leg Curl', '4×10+12', 'Hamstrings'),
  ]),
  _sec('GLUTES', [
    _ex('Bulgarian Split Squat', '4×10/leg', 'Glutes / Quads'),
    _ex('Hip Thrust (heavy)', '4×12', 'Glutes Max'),
  ]),
  _sec('ADDUCTORS / ABDUCTORS / TFL', [
    _ex('★ Adductor + Abductor Machine', '3×15+15', 'Adductors / Abductors'),
    _ex('Lateral Band Walk', '3×20 steps', 'Glutes Med / TFL'),
  ]),
  _sec('CALVES', [
    _ex('★ Standing + Seated Calf Raise', '4×20+15', 'Gastrocnemius / Soleus'),
  ]),
  _sec('EXPLOSIVE', [_ex('Jump Squat', '3×15', 'Quads / Calves / Power')]),
];
final List<Exercise> _p2LegsCore = [
  _ex('Hanging Leg Raise', '4×15', 'Lower Abs'),
  _ex('Reverse Crunch', '3×20', 'Lower Abs'),
  _ex('Plank 1 min', '3×1 min', 'Full Core'),
];

final List<WorkoutSection> _p2FullSections = [
  _sec('FULL POSTERIOR CHAIN', [
    _ex('Hang Power Clean', '5×4', 'Full Posterior Chain'),
    _ex('Push Press', '4×6', 'Shoulders / Triceps / Legs'),
  ]),
  _sec('BACK / LATS', [
    _ex('★ Weighted Pull-Up + Ring Row', '4×6+10', 'Lats / Rhomboids / Biceps'),
  ]),
  _sec('CHEST / SHOULDERS', [
    _ex('★ DB Floor Press + Band Pull-Apart', '3×10+20', 'Chest / Upper Back'),
  ]),
  _sec('POSTERIOR CHAIN', [_ex('Trap Bar Deadlift (heavy)', '4×6', 'Full Posterior Chain')]),
  _sec('ROTATOR CUFF', [
    _ex('★ Face Pull + External Rotation', '3×15+15', 'Rotator Cuff / Rear Delt'),
  ]),
  _sec('FOREARMS / GRIP', [
    _ex("Heavy Farmer's Carry (50m)", '5 rounds', 'Forearms / Grip / Core'),
  ]),
];
final List<Exercise> _p2FullCore = [
  _ex('Pallof Press', '4×12/side', 'Anti-Rotation Core'),
  _ex('Copenhagen Plank', '3×30s/side', 'Adductors / Core'),
  _ex('L-Sit (parallel bars)', '3×15s', 'Hip Flexors / Core'),
];

final List<WorkoutSection> _p2SatCombatSections = [
  _sec('FULL BODY STAMINA', [
    _ex('Shadow Boxing Rounds', '6×3 min', 'Full Body / Cardiovascular', 'Max intensity, vary stance'),
    _ex('Kickboxing Sprint Intervals', '10 rounds', 'Full Body', '30s max / 15s rest'),
  ]),
  _sec('SANDBAG CIRCUIT', [
    _ex('Sandbag Circuit (5 moves)', '5 rounds', 'Full Body', 'Slam→Shoulder→Carry→Squat→Get-up'),
    _ex('Burpee + Knee Strike', '3×12', 'Full Body'),
    _ex('10s Sprint + 30s Shadowbox ×10', '1 round', 'Cardiovascular / Full Body'),
  ]),
];

// ── PHASE 3 WORKOUTS ────────────────────────────────────────────────────────

final List<WorkoutSection> _p3PushSections = [
  _sec('MID CHEST — STRENGTH', [
    _ex('Barbell Bench Press (3RM)', '5×3–5', 'Mid Pectorals', 'Work up to 3 rep max'),
  ]),
  _sec('UPPER/LOWER CHEST + SERRATUS (TRIPLE SET)', [
    _ex('★★ Incline Press + Decline Push-Up + Cable Fly', '4×8+15+12', 'Pectorals / Serratus', 'Zero rest between all 3'),
  ]),
  _sec('ALL 3 DELTOIDS — EXPLOSIVE', [
    _ex('Push Press (explosive)', '4×6', 'All Deltoids / Triceps'),
    _ex('★★ Lateral + Front Raise + Upright Row', '3×15+12+10', 'All 3 Deltoid Heads'),
  ]),
  _sec('ROTATOR CUFF', [_ex('Cable External Rotation', '3×15/side', 'Infraspinatus / Teres Minor')]),
  _sec('TRICEPS — ALL HEADS PEAK', [
    _ex('★★ Close-Grip Bench + OH Ext + Pushdown', '4×10+12+15', 'All 3 Tricep Heads'),
  ]),
  _sec('PEC MINOR / SERRATUS', [
    _ex('Cable Crossover (low to high)', '3×15', 'Pec Minor / Serratus'),
  ]),
];
final List<Exercise> _p3PushCore = [
  _ex('Dragon Flag', '4×8', 'Full Core'),
  _ex('Toes-to-Bar', '4×12', 'Lower Abs / Hip Flexors'),
  _ex('Weighted Oblique Crunch', '3×20/side', 'Obliques'),
  _ex('Plank 90s', '2×90s', 'Full Core'),
];

final List<WorkoutSection> _p3PullSections = [
  _sec('LOWER BACK / ERECTORS', [
    _ex('Conventional Deadlift (near max)', '5×3', 'Erector Spinae / Full Posterior'),
  ]),
  _sec('LATS — WIDTH & THICKNESS', [
    _ex('★★ Pull-Up + Lat Pulldown + Straight-Arm PD', '4×8+10+12', 'Latissimus Dorsi'),
  ]),
  _sec('MID-BACK THICKNESS', [
    _ex('★★ T-Bar Row + Seated Row + Face Pull', '4×8+10+15', 'Rhomboids / Mid Traps / Rear Delt'),
  ]),
  _sec('TRAPS — UPPER & MID', [
    _ex('★ Heavy Shrug + Face Pull', '4×15+15', 'Upper / Mid Trapezius'),
  ]),
  _sec('BICEPS — PEAK', [
    _ex('★★ Barbell Curl + Hammer + Concentration', '3×10+10+10', 'Biceps / Brachialis'),
  ]),
  _sec('FOREARMS — FULL', [
    _ex('★ Wrist Curl + Reverse Curl + Plate Pinch', '3×15+12+30s', 'Full Forearm Development'),
  ]),
  _sec('NECK', [
    _ex('Neck Isometric + Weighted Nod', '3×10s each', 'Neck / SCM / Deep Cervical'),
  ]),
];
final List<Exercise> _p3PullCore = [
  _ex('Hanging Windshield Wiper', '3×10', 'Obliques / Core'),
  _ex('Weighted Russian Twist', '3×25', 'Obliques'),
  _ex('L-Sit + Tuck-to-L', '3×20s', 'Hip Flexors / Core'),
];

final List<WorkoutSection> _p3CombatSections = [
  _sec('FULL KINETIC CHAIN — COMBAT', [
    _ex('Shadow Boxing — Elite Combos', '6×3 min', 'Full Body', 'Slip-counter, pivot-hook, defensive footwork'),
    _ex('Kickboxing Rounds — Full Pace', '5×3 min', 'Full Body', 'High kick + spinning back kick'),
  ]),
  _sec('TOTAL BODY — HEAVY SANDBAG', [
    _ex('Sandbag Tabata', '8 rounds', 'Full Body', 'Rotate: slam, clean, carry, shouldering'),
    _ex('Sandbag Bear Crawl', '4×20m', 'Full Body / Core'),
    _ex('Sandbag Rotational Slam', '4×8/side', 'Obliques / Hip Rotators'),
  ]),
  _sec('NECK / HEAD STABILITY', [
    _ex('Advanced Neck Bridge (gentle)', '3×10s', 'Neck / Deep Cervical'),
  ]),
];
final List<Exercise> _p3CombatCore = [
  _ex('Med Ball Rotational Slam', '4×10/side', 'Obliques / Core'),
  _ex('Landmine Twist', '3×12/side', 'Spinal Rotators / Obliques'),
  _ex('Hollow-to-Arch Rock', '3×10', 'Full Core'),
];

final List<WorkoutSection> _p3LegsSections = [
  _sec('QUADS — STRENGTH PEAK', [
    _ex('Barbell Back Squat (near max)', '5×4', 'Quadriceps', 'Work up to near max'),
    _ex('★★ Front Squat + Jump Squat + Leg Extension', '4×8+10+15', 'Quads / VMO / Power'),
  ]),
  _sec('HAMSTRINGS', [
    _ex('★★ Romanian DL + Leg Curl + Nordic Curl', '4×8+12+6', 'All Hamstring Heads'),
  ]),
  _sec('GLUTES', [
    _ex('Heavy Hip Thrust', '4×10', 'Glutes Max'),
    _ex('Bulgarian Split Squat (loaded)', '4×10/leg', 'Glutes / Quads'),
  ]),
  _sec('ADDUCTORS / ABDUCTORS / HIP ROTATORS', [
    _ex('★ Adductor Squeeze + Lateral Band Walk', '3×20+20', 'Adductors / Glutes Med'),
    _ex('Cable Hip Abduction (standing)', '3×15/side', 'Glutes Med / Abductors'),
  ]),
  _sec('CALVES — FULL DEVELOPMENT', [
    _ex('★ Standing + Seated Calf Raise', '5×25+20', 'Gastrocnemius / Soleus'),
    _ex('Single-Leg Calf Raise', '3×20/leg', 'Gastrocnemius / Balance'),
  ]),
];
final List<Exercise> _p3LegsCore = [
  _ex('Toes-to-Bar', '4×15', 'Lower Abs / Hip Flexors'),
  _ex('Weighted Reverse Crunch', '3×20', 'Lower Abs'),
  _ex('Pike Hold (straight legs)', '3×30s', 'Core / Hip Flexors'),
];

final List<WorkoutSection> _p3FullSections = [
  _sec('EXPLOSIVE POWER', [
    _ex('Hang Snatch (or Power Clean)', '5×3', 'Full Body Power'),
    _ex('Push Jerk', '4×4', 'Shoulders / Full Body'),
  ]),
  _sec('BACK + BICEPS', [
    _ex('★ Weighted Pull-Up + Narrow Row', '5×5+8', 'Lats / Biceps / Mid Back'),
  ]),
  _sec('CHEST + SHOULDER', [
    _ex('★ Weighted Dip + DB Lateral Raise', '4×8+15', 'Chest / Triceps / Side Delt'),
  ]),
  _sec('LOWER BODY', [_ex('Trap Bar DL (heavy)', '5×3', 'Full Posterior Chain')]),
  _sec('ROTATOR CUFF', [
    _ex('★ Face Pull + YTW Raises', '3×15 each', 'Rotator Cuff / Rear Delt / Lower Traps'),
  ]),
  _sec('GRIP / FOREARMS', [
    _ex("Heavy Farmer's Carry (60m)", '5 rounds', 'Forearms / Grip / Core'),
  ]),
];
final List<Exercise> _p3FullCore = [
  _ex('Dragon Flag', '4×8', 'Full Core'),
  _ex('Pallof Press + Chop', '3×12/side', 'Anti-Rotation + Rotation Core'),
  _ex('Ab Wheel Single-Arm', '3×6/side', 'Deep Core / Obliques'),
  _ex('Plank 2 min', '2×2 min', 'Full Core'),
];

final List<WorkoutSection> _p3SatCombatSections = [
  _sec('ELITE COMBAT STAMINA', [
    _ex('Shadow Boxing — Elite Pace', '5×5 min', 'Full Body', 'Full combos, footwork mastery'),
    _ex('Kickboxing Peak Rounds', '5×3 min', 'Full Body', 'Max output, full technique'),
  ]),
  _sec('SANDBAG DEATH CIRCUIT', [
    _ex('Sandbag Death Circuit', '5 rounds', 'Full Body',
        'Slam×10→Squat×10→Carry 20m→Shoulder×5, no rest'),
    _ex('Burpee Shadowbox Finisher', '3×15', 'Full Body', 'Burpee→stand→3-punch combo'),
  ]),
];

final List<WorkoutSection> _deloadSections = [
  _sec('DELOAD — LIGHT TRAINING', [
    _ex('Compound lifts at 60% normal weight', '2×12', 'All Major Groups', 'Same movements, significantly reduced load'),
    _ex('Focus on mobility & form', 'Full ROM', 'All Groups'),
    _ex('Light Shadow Boxing', '3×2 min', 'Active Recovery'),
    _ex('Light Core Work', '2×10', 'Core'),
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// PLAN BUILDER
// ─────────────────────────────────────────────────────────────────────────────

class FitnessPlan {
  // Weekly day types: Mon=push, Tue=pull, Wed=combat, Thu=legs, Fri=full, Sat=combat, Sun=rest
  // April 10 2025 = Thursday → patternIndex 3 (legs)

  static WorkoutDay buildDay(int dayNumber, {DateTime? startDate}) {
    final start = startDate ?? DateTime(2025, 4, 10);
    final date = start.add(Duration(days: dayNumber - 1));
    final weekNumber = ((dayNumber - 1) ~/ 7) + 1;
    final int phase = weekNumber <= 4 ? 1 : (weekNumber <= 8 ? 2 : 3);
    final String phaseLabel = phase == 1
        ? 'P1 — Foundation'
        : phase == 2
            ? 'P2 — Intensity'
            : 'P3 — Peak Shred';

    // Deload weeks: week 4 and week 8
    final isDeload = (weekNumber == 4 || weekNumber == 8);

    // Day of week: 0=Mon,1=Tue,2=Wed,3=Thu,4=Fri,5=Sat,6=Sun
    final patternIndex = (date.weekday - 1) % 7; // weekday: 1=Mon,...7=Sun → 0-6

    // Sunday = always rest
    if (patternIndex == 6) {
      return WorkoutDay(
        dayNumber: dayNumber, date: date,
        type: WorkoutType.rest, label: 'ACTIVE REST',
        focus: 'Yoga · Mobility · Foam Rolling',
        warmup: '',
        sections: _restSections, coreFinisher: [],
        weekNumber: weekNumber, phase: phase,
        phaseLabel: phaseLabel, isDeload: false,
      );
    }

    // Deload (any training day in deload week)
    if (isDeload) {
      return WorkoutDay(
        dayNumber: dayNumber, date: date,
        type: WorkoutType.deload, label: 'DELOAD — 40% Volume',
        focus: 'Active Recovery · Light Loads · Form Focus',
        warmup: '10 min easy movement + full mobility work',
        sections: _deloadSections, coreFinisher: [],
        weekNumber: weekNumber, phase: phase,
        phaseLabel: phaseLabel, isDeload: true,
      );
    }

    // Regular training days
    switch (patternIndex) {
      case 0: // Monday — Push
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.push,
          label: phase == 1 ? 'PUSH DAY' : phase == 2 ? 'PUSH — HEAVY' : 'PUSH — PEAK',
          focus: 'Chest · Shoulders · Triceps · Serratus',
          warmup: '5 min bike + shoulder CARs + chest opener stretch',
          sections: phase == 1 ? _p1PushSections : phase == 2 ? _p2PushSections : _p3PushSections,
          coreFinisher: phase == 1 ? _p1PushCore : phase == 2 ? _p2PushCore : _p3PushCore,
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      case 1: // Tuesday — Pull
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.pull,
          label: phase == 1 ? 'PULL DAY' : phase == 2 ? 'PULL — HEAVY' : 'PULL — PEAK',
          focus: 'Back · Biceps · Traps · Forearms · Neck',
          warmup: 'Band pull-aparts 2×15 + thoracic rotation + cat-cow',
          sections: phase == 1 ? _p1PullSections : phase == 2 ? _p2PullSections : _p3PullSections,
          coreFinisher: phase == 1 ? _p1PullCore : phase == 2 ? _p2PullCore : _p3PullCore,
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      case 2: // Wednesday — Combat
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.combat,
          label: phase == 1 ? 'COMBAT & CORE' : phase == 2 ? 'COMBAT CONDITIONING' : 'COMBAT — ELITE',
          focus: 'Shadow Boxing · Kickboxing · Sandbag · Core',
          warmup: 'Jump rope 3 min + neck rolls + hip circles + shadow jabs',
          sections: phase == 1 ? _p1CombatSections : phase == 2 ? _p2CombatSections : _p3CombatSections,
          coreFinisher: phase == 1 ? _p1CombatCore : phase == 2 ? _p2CombatCore : _p3CombatCore,
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      case 3: // Thursday — Legs
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.legs,
          label: phase == 1 ? 'LEG DAY' : phase == 2 ? 'LEGS — VOLUME' : 'LEGS — PEAK',
          focus: 'Quads · Hamstrings · Glutes · Calves · Adductors · Hip Rotators',
          warmup: 'Leg swings 2×12 + goblet squat 2×10 + hip flexor stretch',
          sections: phase == 1 ? _p1LegsSections : phase == 2 ? _p2LegsSections : _p3LegsSections,
          coreFinisher: phase == 1 ? _p1LegsCore : phase == 2 ? _p2LegsCore : _p3LegsCore,
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      case 4: // Friday — Full Body
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.fullBody,
          label: phase == 1 ? 'FULL BODY POWER' : phase == 2 ? 'POWER & STRENGTH' : 'FULL BODY — PEAK',
          focus: 'Olympic Lifts · All Major Groups · Rotator Cuff',
          warmup: '5 min treadmill + PVC pass-throughs + thoracic extension',
          sections: phase == 1 ? _p1FullSections : phase == 2 ? _p2FullSections : _p3FullSections,
          coreFinisher: phase == 1 ? _p1FullCore : phase == 2 ? _p2FullCore : _p3FullCore,
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      case 5: // Saturday — Combat
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.combat,
          label: phase == 1 ? 'COMBAT CONDITIONING' : phase == 2 ? 'COMBAT STAMINA' : 'ELITE COMBAT',
          focus: 'Full Combat Session · Sandbag · Stamina · Full Body',
          warmup: 'Jog 3 min + dynamic kicks + shadow boxing 1 round',
          sections: phase == 1 ? _p1SatCombatSections : phase == 2 ? _p2SatCombatSections : _p3SatCombatSections,
          coreFinisher: [],
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );

      default:
        return WorkoutDay(
          dayNumber: dayNumber, date: date,
          type: WorkoutType.rest, label: 'ACTIVE REST',
          focus: 'Yoga · Mobility · Foam Rolling',
          warmup: '', sections: _restSections, coreFinisher: [],
          weekNumber: weekNumber, phase: phase, phaseLabel: phaseLabel, isDeload: false,
        );
    }
  }

  /// Generate the full plan (default: 84 days from April 10, 2025)
  /// Extended plans can be generated beyond day 84
  static List<WorkoutDay> generatePlan({
    DateTime? startDate,
    int totalDays = 84,
  }) {
    return List.generate(
      totalDays,
      (i) => buildDay(i + 1, startDate: startDate),
    );
  }
}
