*&---------------------------------------------------------------------*
*& REPORT YWPK_SQL_EDITOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zsql_simple_console.

data:gv_query_string     type string,
     gv_popup_display(1) value 'X',
     gv_with_comment(1)  value '',
     gv_new_format(1)    value 'X',
     gv_max_row          type i value '9999'.

data: go_sql_container   type ref to cl_gui_custom_container,
      go_sql_editor      type ref to cl_gui_textedit,
      go_grid            type ref to cl_gui_alv_grid,
      go_container_left  type ref to cl_gui_container,
      go_container_right type ref to cl_gui_container,
      go_splitter        type ref to cl_gui_splitter_container,
      go_alv             type ref to cl_salv_table,
      ok_code            type syst-ucomm.

start-of-selection.
  call screen 100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status 'YPF100'.

  if go_sql_editor is initial.

    create object go_sql_container
      exporting
        container_name = 'SQL'.

    create object go_splitter
      exporting
        parent  = go_sql_container
        rows    = 1
        columns = 2.

    go_splitter->set_column_width(
      exporting
        id = 1
        width = 30
    ).

    "初始化SQL编辑器
    call method go_splitter->get_container
      exporting
        row       = 1
        column    = 1
      receiving
        container = go_container_left.

    create object go_sql_editor
      exporting
        wordwrap_mode          =
                                 cl_gui_textedit=>wordwrap_at_fixed_position
        parent                 = go_container_left
      exceptions
        error_cntl_create      = 1
        error_cntl_init        = 2
        error_cntl_link        = 3
        error_dp_create        = 4
        gui_type_not_supported = 5
        others                 = 6.

    "初始化ALV
    call method go_splitter->get_container
      exporting
        row       = 1
        column    = 2
      receiving
        container = go_container_right.
  endif.

* SET TITLEBAR 'xxx'.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.

  case ok_code.
    when 'BACK'.
      leave to screen 0.
    when 'CLS'.
      perform clear_sql_editor.
    when 'RUN'.
      perform excute_sql.
    when others.
  endcase.
endmodule.
*&---------------------------------------------------------------------*
*& Form EXCUTE_SQL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form excute_sql .
  data:lt_sql             type table of tdline,
       lv_query_statement type string.

  go_sql_editor->get_text_as_r3table(
  importing
    table = lt_sql
   ).

  if lt_sql is initial.
    return.
  endif.

  loop at lt_sql into data(ls_sql).
    lv_query_statement = lv_query_statement && space && ls_sql.
  endloop.

  translate lv_query_statement to upper case.

  try .
      data(lo_sql_handler) = cl_adt_dp_open_sql_handler=>get_instance(
      exporting
        iv_query_string = lv_query_statement
        iv_new_format = gv_new_format
        iv_remove_comments = gv_with_comment
      ).

      data:lr_result type ref to data.
      lo_sql_handler->get_query_result(
      exporting
        iv_row_count = gv_max_row
      importing
        er_result = lr_result
        ).

    catch cx_adt_datapreview_common into data(lo_sql_error).
    DATA(lv_error_message) = lo_sql_error->get_longtext( ).
      message lv_error_message type 'E'.
  endtry.

  field-symbols:<fs_result_tab> type index table.
  assign lr_result->* to <fs_result_tab>.
  data(lv_result_line) = lines( <fs_result_tab> ).

  if go_alv is not bound.
    try .
        cl_salv_table=>factory(
        exporting
          r_container = go_container_right
        importing
          r_salv_table = go_alv
        changing
          t_table = <fs_result_tab> ).

        data(lo_grid_setting) = go_alv->get_display_settings( ).
        data(lv_alv_title) = conv lvc_title( lv_result_line && '条结果').
        lo_grid_setting->set_list_header( lv_alv_title ).

        data(lo_functions) = go_alv->get_functions( ).
        lo_functions->set_all( abap_true ).

        go_alv->display( ).
      catch cx_salv_msg.

    endtry.
  else.

    lo_grid_setting = go_alv->get_display_settings( ).
    lv_alv_title =  lv_result_line && '条结果'.
    lo_grid_setting->set_list_header( lv_alv_title ).

    go_alv->set_data(
    changing
      t_table = <fs_result_tab>
    ).

    go_alv->refresh( ).
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form CLEAR_SQL_EDITOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form clear_sql_editor .

  if go_sql_editor is bound.
    data:lt_sql             type table of tdline.
    go_sql_editor->set_text_as_r3table( lt_sql ).
  endif.

endform.
