class ZGIT_CL_TABLE_PIVOT definition
  public
  final
  create public .

public section.

  types:
    begin of gts_pivote,
        fieldname type fieldname,
        values    type fieldname_tab,
      end of gts_pivote .
  types:
    gtt_pivotes type table of gts_pivote with key fieldname .

  class-methods PIVOT
    importing
      !IV_PIVOT type GTT_PIVOTES
      !IT_TABLE type STANDARD TABLE
    returning
      value(OR_TABLE) type ref to DATA .
protected section.
private section.
ENDCLASS.



CLASS ZGIT_CL_TABLE_PIVOT IMPLEMENTATION.


  method PIVOT.
    data lo_structdescr type ref to cl_abap_structdescr.
    data lo_tabledescr type ref to cl_abap_tabledescr.

*   Crear pivot table
*   En primer lugar obtener los campos de la tabla de entrada
    lo_tabledescr ?= cl_abap_tabledescr=>describe_by_data( p_data = it_table ).
    lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
    data(lt_components) = lo_structdescr->get_components( ).
*   Crear una nueva lista de campos, eliminando los que van a pivotar
    data(lt_new_components) = lt_components[].
    loop at iv_pivot into data(ls_pivot).
*     Eliminar el pivote de la tabla de salida
      delete lt_new_components where name = ls_pivot-fieldname.
*     Eliminar los campos valor
      loop at ls_pivot-values into data(lv_value_field).
        delete lt_new_components where name = lv_value_field.
      endloop.
    endloop.

    data lt_new_components_added type abap_component_tab.
*   Recorrer la tabla de entrada, para obtener los valores pivote
*   y añadir los campos necesarios para cada valor del pivote
    loop at it_table assigning field-symbol(<ls_line>).
      loop at iv_pivot into ls_pivot.
        assign component ls_pivot-fieldname of structure <ls_line>
          to field-symbol(<pivot_value>).
        loop at ls_pivot-values into lv_value_field.
          read table lt_new_components_added transporting no fields
            with key name = |{ lv_value_field }_{ <pivot_value> }|.
*       Si no hemos creado ya el campo, lo creamos
*       usando la estructura original como referencia
          if sy-subrc eq 0. exit. endif.
          read table lt_components into data(ls_component)
            with key name = lv_value_field.
          ls_component-name = |{ lv_value_field }_{ <pivot_value> }|.
          append ls_component to lt_new_components_added.
        endloop.
      endloop.
    endloop.
    sort lt_new_components_added.
    append lines of lt_new_components_added to lt_new_components.

*   Crear la tabla de salida
    field-symbols: <f_data> type table.
    lo_structdescr = cl_abap_structdescr=>create( lt_new_components ).
    lo_tabledescr = cl_abap_tabledescr=>create( lo_structdescr ).
    create data or_table type handle lo_tabledescr.
    assign or_table->* to <f_data>.

*   Crear una línea de cabecera la tabla de salida
    data lr_line type ref to data.
    create data lr_line type handle lo_structdescr.
    assign lr_line->* to field-symbol(<f_line>).

*   Rellenar la tabla de salida.
    loop at it_table assigning <ls_line>.
*     Rellenar linea de salida
      clear <f_line>.
*     En primer lugar rellenar todos los campos que no pivotan
*     que son los comunes entre la estructura original y la nueva
      move-corresponding <ls_line> to <f_line>.
      loop at iv_pivot into ls_pivot.
*     Obtener el valor del pivote
        assign component ls_pivot-fieldname of structure <ls_line>
          to <pivot_value>.
*     Establecer el valor de las columnas nuevas que se corresponden
*     con el valor del pivote
        loop at ls_pivot-values into lv_value_field.
          assign component lv_value_field of structure <ls_line>
            to field-symbol(<f_field_origen>).
          data(l_fieldname) = |{ lv_value_field }_{ <pivot_value> }|.
          assign component l_fieldname of structure <f_line>
            to field-symbol(<f_field_destino>).
          <f_field_destino> = <f_field_origen>.
        endloop.
      endloop.
*     Añadir la línea agrupando los valores de las columnas nuevas para
*     cada combinación de campos comunes entre la tabla vieja y la nueva
      collect <f_line> into <f_data>.
    endloop.
    sort <f_data>.
  endmethod.
ENDCLASS.
