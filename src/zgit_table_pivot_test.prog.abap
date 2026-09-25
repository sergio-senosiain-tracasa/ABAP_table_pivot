*&---------------------------------------------------------------------*
*& Report  ZGIT_TABLE_PIVOT_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zgit_table_pivot_test.

types: begin of ts_test,
         pernr like pernr-pernr,
         lgart like pa0015-lgart,
         betrg like pa0015-betrg,
         anzhl like pa0015-anzhl,
         awart like p2001-awart,
         stdaz like p2001-stdaz,
       end of ts_test,
       tt_test type table of ts_test with default key.

* Datos de ejemplo
data(lt_test) = value tt_test(
  ( pernr = '11111111' lgart = 'CC01' betrg = 100 anzhl = 0 awart = '1000' stdaz = '10' )
  ( pernr = '11111111' lgart = 'CC02' betrg = 0 anzhl = 10  awart = '2000' stdaz = '10' )
  ( pernr = '11111112' lgart = 'CC01' betrg = 200 anzhl = 0  awart = '1000' stdaz = '10' )
  ( pernr = '11111112' lgart = 'CC02' betrg = 0 anzhl = 20  awart = '2000' stdaz = '10' )
  ( pernr = '11111112' lgart = 'CC03' betrg = 300 anzhl = 30  awart = '1000' stdaz = '10' )
).

cl_demo_output=>display( lt_test ).

* Pivotar la tabla
data(lt_pivot) = value zcl_hr_hg_table=>gtt_pivotes(
  ( fieldname = 'LGART' values = value fieldname_tab( ( 'BETRG' ) ( 'ANZHL' ) ) )
  ( fieldname = 'AWART' values = value fieldname_tab( ( 'STDAZ' ) ) )
).
data(lr_data) = zgit_cl_table_pivot=>pivot(
    exporting iv_pivot  = lt_pivot
              it_table  = lt_test ).
* Asignar a field symbol
field-symbols: <output_table> type table.
assign lr_data->* to <output_table>.

cl_demo_output=>display( <output_table> ).
