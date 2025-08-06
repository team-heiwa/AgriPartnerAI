import 'package:flutter/material.dart';

class ActionsScreen extends StatefulWidget {
  const ActionsScreen({super.key});

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  final List<KanbanColumn> _columns = [
    KanbanColumn(
      id: 'new',
      title: 'New',
      cards: [
        ActionCard(
          id: '1',
          title: 'Field inspection needed',
          description: 'Check sector A for pest damage',
          priority: Priority.high,
          dueDate: DateTime.now().add(const Duration(days: 2)),
        ),
        ActionCard(
          id: '2',
          title: 'Irrigation system check',
          description: 'Monthly maintenance',
          priority: Priority.medium,
          dueDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ],
    ),
    KanbanColumn(
      id: 'in_progress',
      title: 'In Progress',
      cards: [
        ActionCard(
          id: '3',
          title: 'Soil testing',
          description: 'Collect samples from sectors B and C',
          priority: Priority.high,
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ],
    ),
    KanbanColumn(
      id: 'completed',
      title: 'Completed',
      cards: [
        ActionCard(
          id: '4',
          title: 'Fertilizer application',
          description: 'Applied to all sectors',
          priority: Priority.low,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddActionDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: _columns.map((column) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              column.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${column.cards.length}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: DragTarget<ActionCard>(
                          onAccept: (card) {
                            setState(() {
                              // Remove from old column
                              for (var col in _columns) {
                                col.cards.removeWhere((c) => c.id == card.id);
                              }
                              // Add to new column
                              column.cards.add(card);
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return ListView.builder(
                              itemCount: column.cards.length,
                              itemBuilder: (context, index) {
                                final card = column.cards[index];
                                return Draggable<ActionCard>(
                                  data: card,
                                  feedback: Material(
                                    elevation: 4,
                                    child: Container(
                                      width: 300,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(card.title),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: _buildActionCard(card),
                                  ),
                                  child: _buildActionCard(card),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(ActionCard card) {
    Color priorityColor;
    switch (card.priority) {
      case Priority.high:
        priorityColor = Colors.red;
        break;
      case Priority.medium:
        priorityColor = Colors.orange;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(card.dueDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.mic, size: 20),
                onPressed: () => _showVoiceMemoDialog(card),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0) return 'In $difference days';
    return '${-difference} days ago';
  }

  void _showAddActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Add new action logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showVoiceMemoDialog(ActionCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Voice Memo - ${card.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, size: 64, color: Colors.blue[600]),
            const SizedBox(height: 16),
            const Text('Tap to record voice memo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class KanbanColumn {
  final String id;
  final String title;
  final List<ActionCard> cards;

  KanbanColumn({
    required this.id,
    required this.title,
    required this.cards,
  });
}

class ActionCard {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;

  ActionCard({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });
}

enum Priority { high, medium, low }