import 'package:flutter/foundation.dart';

@immutable
class VaidyaCareDoctorProfile {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final List<String> tags;
  final List<String> focus;
  final String imageAsset;

  const VaidyaCareDoctorProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.tags,
    required this.focus,
    required this.imageAsset,
  });

  static const List<VaidyaCareDoctorProfile> catalog = [
    VaidyaCareDoctorProfile(
      id: 'nischay-maharan',
      name: 'Dr. Nischay Maharan',
      title: 'General Physician AI',
      specialty: 'Primary Care',
      tags: [
        'Primary Care',
        'Symptom Evaluation',
        'Preventive Health',
        'Vital Review',
        'Risk Assessment',
      ],
      focus: ['symptom evaluation', 'vital', 'vital review', 'preventive care'],
      imageAsset: 'assets/images/doctor_1.png',
    ),
    VaidyaCareDoctorProfile(
      id: 'trishan-wagle',
      name: 'Dr. Trishan Wagle',
      title: 'Cardiology AI Specialist',
      specialty: 'Cardiology',
      tags: [
        'Heart Health',
        'Blood Pressure Monitoring',
        'Cholesterol Analysis',
        'Cardiac Risk',
        'ECG Guidance',
      ],
      focus: ['heart health', 'blood pressure', 'cholesterol analysis'],
      imageAsset: 'assets/images/doctor_2.jpg',
    ),
    VaidyaCareDoctorProfile(
      id: 'kiran-rana',
      name: 'Dr. Kiran Rana',
      title: 'Respiratory Health AI Specialist',
      specialty: 'Respiratory',
      tags: [
        'Lung Function',
        'Breathing Assessment',
        'Oxygen Monitoring',
        'Infection Screening',
        'Asthma Care',
      ],
      focus: ['lung function', 'breathing assessment', 'asthma care'],
      imageAsset: 'assets/images/doctor.png',
    ),
    VaidyaCareDoctorProfile(
      id: 'albert-maharan',
      name: 'Dr. Albert Maharan',
      title: 'Endocrinology AI Specialist',
      specialty: 'Endocrinology',
      tags: [
        'Diabetes Care',
        'Glucose Tracking',
        'Thyroid Health',
        'Hormonal Balance',
        'Metabolic Risk',
      ],
      focus: ['diabetes care', 'glucose tracking', 'thyroid health'],
      imageAsset: 'assets/images/doctor.png',
    ),
    VaidyaCareDoctorProfile(
      id: 'rabin-tamang',
      name: 'Dr. Rabin Tamang',
      title: 'Mental Wellness AI Specialist',
      specialty: 'Mental Wellness',
      tags: [
        'Stress Management',
        'Anxiety Support',
        'Mood Tracking',
        'Sleep Health',
        'Behavioral Insights',
      ],
      focus: ['stress management', 'mood tracking', 'sleep health'],
      imageAsset: 'assets/images/doctor.png',
    ),
  ];
}
