import 'package:dcm_flutter/repositories/model/user.dart';
import 'package:dcm_flutter/resources/strings.dart';
import 'package:dcm_flutter/view/dialogs/abrequest_check_bottomsheet.dart';
import 'package:dcm_flutter/view/dialogs/pictureselect_bottomsheet.dart';
import 'package:dcm_flutter/view/widgets/drop_down.dart';
import 'package:dcm_flutter/viewmodel/abrequest_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbRequestFragment extends StatefulWidget {
  final User _user;

  const AbRequestFragment(this._user, {Key? key}) : super(key: key);

  @override
  State<AbRequestFragment> createState() => _AbRequestFragmentState(_user);
}

class _AbRequestFragmentState extends State<AbRequestFragment> {
  bool _menuExpanded = false;
  bool _fileAttached = false;
  AbRequestViewModel? _viewModel;
  var _specialTimes = [];

  var _date = DateTime.now();
  var _dFormat = DateFormat('dd.MM.yyyy');
  final _dayTypes = [Strings.menuDayFull, Strings.menuDayHalf];
  final _abTypeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startHalfController = TextEditingController();
  final _stopDateController = TextEditingController();
  final _stopHalfController = TextEditingController();
  final _commentController = TextEditingController();
  final _user;

  _AbRequestFragmentState(this._user);

  void _openDatePicker() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2099, 12),
      helpText: 'Datum auswählen.',
    );
    if (newDate != null) {
      setState(() {
        _date = newDate;
        _startDateController.text = _dFormat.format(_date);
      });
    }
  }

  void _checkRequest() {
    AbRequestCheckBottomSheet(_viewModel!).show(context);
  }

  void _removeAttachment() {}

  @override
  void initState() {
    _viewModel = AbRequestViewModel(_user);
    _viewModel!.getAbRequestTypes().then((value) {
      setState(() {
        _specialTimes = value;
        _startDateController.text = _dFormat.format(_date);
        _stopDateController.text = _dFormat.format(_date);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropDownInputField(
              hint: Strings.hintAbType, options: _specialTimes, controller: _abTypeController, showInitValue: false),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(Strings.txtStartDate, style: textTheme.headline2),
          ),
          Row(
            children: [
              Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: _openDatePicker,
                      textAlign: TextAlign.start,
                      decoration:
                          const InputDecoration(prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: DropDownInputField(
                      showInitValue: true,
                      options: _dayTypes,
                      controller: _startHalfController,
                    )),
              )
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(Strings.txtStopDate, style: textTheme.headline2),
          ),
          Row(
            children: [
              Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: TextFormField(
                      controller: _stopDateController,
                      readOnly: true,
                      onTap: _openDatePicker,
                      textAlign: TextAlign.start,
                      decoration:
                          const InputDecoration(prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: DropDownInputField(
                      showInitValue: true,
                      options: _dayTypes,
                      controller: _stopHalfController,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.text,
            maxLines: 5,
            minLines: 3,
            controller: _commentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: Strings.hintComment,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              hintText: Strings.hintComment,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  PictureSelectBottomSheet.show(context);
                },
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text(Strings.btnAttach),
              ),
              const SizedBox(width: 16),
              Visibility(
                  visible: _fileAttached,
                  child: GestureDetector(onTap: _removeAttachment, child: const Text(Strings.btnRemoveAttachment)))
            ],
          ),
          const SizedBox(height: 8),
          Align(
            child: ElevatedButton.icon(
              onPressed: _checkRequest,
              icon: const Icon(Icons.save, size: 18),
              label: const Text(Strings.btnAbCheck, style: TextStyle(fontSize: 18)),
            ),
            alignment: Alignment.centerRight,
          )
        ],
      ),
    ));
  }
}
