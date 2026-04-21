import 'package:flutter/material.dart';
import '../../core/app_globals.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

Color get _creamBg => AppGlobals.creamBg;
Color get _creamCard => AppGlobals.creamCard;
Color get _tanButton => AppGlobals.tanButton;
Color get _textMain => AppGlobals.textMain;
Color get _textMuted => AppGlobals.textMuted;
Color get _primaryBlack => AppGlobals.primaryBlack;
Color get _vitalSuccess => AppGlobals.vitalSuccess;
Color get _dangerRed => AppGlobals.dangerRed;

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<JournalProvider>().entries;

    return Scaffold(
      backgroundColor: _creamBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryBlack,
        foregroundColor: _creamBg,
        onPressed: () => _openEditor(context),
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Journal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _textMain,
              ),
            ),
            Text(
              'Personal health observations',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
            SizedBox(height: 24),
            if (entries.isEmpty)
              const _EmptyState()
            else
              Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    Dismissible(
                      key: Key(entries[i].id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        context.read<JournalProvider>().remove(entries[i].id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Entry deleted.'),
                            backgroundColor: _dangerRed,
                          ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: _dangerRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete_outline, color: _creamBg),
                      ),
                      child: _EntryCard(entry: entries[i]),
                    ),
                    if (i != entries.length - 1) SizedBox(height: 12),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  static void _openEditor(BuildContext context, {JournalEntry? existing}) {
    showDialog(
      context: context,
      builder: (_) => _EntryEditorDialog(existing: existing),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _creamCard,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          children: [
            Text('📝', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'No journal entries yet',
              style: TextStyle(
                color: _textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap the + button to jot down your first note.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ],
        ),
      );
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final edited = entry.updatedAt.difference(entry.createdAt).inMinutes > 1;
    return Container(
      decoration: BoxDecoration(
        color: _creamCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDialog(
          context: context,
          builder: (_) => _EntryEditorDialog(existing: entry),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _tanButton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.edit_outlined,
                        color: _primaryBlack, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title.isEmpty ? 'Untitled' : entry.title,
                          style: TextStyle(
                            color: _textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          edited
                              ? 'Updated ${_fmt(entry.updatedAt)}'
                              : _fmt(entry.createdAt),
                          style: TextStyle(
                              color: _textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(Icons.delete_outline,
                        color: _dangerRed, size: 20),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              if (entry.body.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  entry.body,
                  style: TextStyle(color: _textMain, fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _creamCard,
        title: Text('Delete entry?',
            style:
                TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${entry.title.isEmpty ? 'Untitled' : entry.title}" permanently?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _dangerRed),
            onPressed: () {
              ctx.read<JournalProvider>().remove(entry.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: _creamBg)),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour == 0
        ? 12
        : (d.hour > 12 ? d.hour - 12 : d.hour);
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} • $hh:$mm $ampm';
  }
}

class _EntryEditorDialog extends StatefulWidget {
  final JournalEntry? existing;
  const _EntryEditorDialog({this.existing});

  @override
  State<_EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<_EntryEditorDialog> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _body = TextEditingController(text: widget.existing?.body ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) return;
    setState(() => _saving = true);
    final provider = context.read<JournalProvider>();
    if (widget.existing == null) {
      await provider.add(title: title, body: body);
    } else {
      await provider.update(widget.existing!.id, title: title, body: body);
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _vitalSuccess,
      content: Text(widget.existing == null ? 'Entry saved.' : 'Entry updated.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return AlertDialog(
      backgroundColor: _creamCard,
      title: Text(editing ? 'Edit Entry' : 'New Entry',
          style:
              TextStyle(color: _textMain, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(controller: _title, label: 'Title'),
            SizedBox(height: 12),
            _field(
              controller: _body,
              label: 'Write your observation…',
              maxLines: 6,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: _textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _primaryBlack),
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _creamBg),
                )
              : Text(editing ? 'Update' : 'Save',
                  style: TextStyle(color: _creamBg)),
        ),
      ],
    );
  }
}

Widget _field({
  required TextEditingController controller,
  required String label,
  int maxLines = 1,
}) =>
    TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textMuted),
        alignLabelWithHint: maxLines > 1,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _tanButton),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryBlack),
        ),
      ),
      style: TextStyle(color: _textMain),
    );
