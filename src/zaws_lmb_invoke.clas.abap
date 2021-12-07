class zaws_lmb_invoke definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

    constants: begin of invocation_type,
                 request_response type string value `RequestResponse`,
                 event            type string value `Event`,
                 dry_run          type string value `DryRun`,
               end of invocation_type.

    constants: begin of log_type,
                 none type string value `None`,
                 tail type string value `Tail`,
               end of log_type.

    methods constructor.

    methods set_access_key importing access_key type string
                           returning value(_me) type ref to zaws_lmb_invoke.

    methods set_secret_key importing secret_key type string
                           returning value(_me) type ref to zaws_lmb_invoke.

    methods set_region importing region     type string
                       returning value(_me) type ref to zaws_lmb_invoke.

    methods set_function_name importing function_name type string
                              returning value(_me)    type ref to zaws_lmb_invoke.

    methods set_client_context importing client_context type string
                               returning value(_me)     type ref to zaws_lmb_invoke.

    methods set_invocation_type importing invocation_type type string
                                returning value(_me)      type ref to zaws_lmb_invoke.

    methods set_log_type importing log_type   type string
                         returning value(_me) type ref to zaws_lmb_invoke.

    methods set_qualifier importing qualifier  type string
                          returning value(_me) type ref to zaws_lmb_invoke.

    methods set_payload importing payload    type string
                        returning value(_me) type ref to zaws_lmb_invoke.

    methods execute exporting status_code type string
                              result      type string.

  protected section.
  private section.
    methods set_query_parameter importing name  type string
                                          value type string.

    methods set_header importing name  type string
                                 value type string.

    data query_parameters type zaws_sigv4_utilities=>http_query_parameters.
    data headers type zaws_sigv4_utilities=>http_headers.
    data header_names type zaws_sigv4_utilities=>http_header_names.
    data access_key type string.
    data secret_key type string.
    data region type string.
    data function_name type string.
    data payload type string value ``.
endclass.



class zaws_lmb_invoke implementation.
  method constructor.
    set_invocation_type( zaws_lmb_invoke=>invocation_type-request_response ).
  endmethod.

  method set_access_key.
    me->access_key = access_key.
    _me = me.
  endmethod.

  method set_region.
    me->region = region.
    _me = me.
  endmethod.

  method set_secret_key.
    me->secret_key = secret_key.
    _me = me.
  endmethod.

  method set_function_name.
    me->function_name = function_name.
    _me = me.
  endmethod.

  method set_client_context.
    set_header( name = 'X-Amz-Client-Context' value = client_context ).
    _me = me.
  endmethod.

  method set_invocation_type.
    set_header( name = 'X-Amz-Invocation-Type' value = invocation_type ).
    _me = me.
  endmethod.

  method set_log_type.
    set_header( name = 'X-Amz-Log-Type' value = log_type ).
    _me = me.
  endmethod.

  method set_qualifier.
    set_query_parameter( name = 'Qualifier' value = qualifier ).
    _me = me.
  endmethod.

  method set_payload.
    me->payload = payload.
    _me = me.
  endmethod.

  method set_query_parameter.
    read table query_parameters
      assigning field-symbol(<query_parameter>)
      with key name = name.

    if sy-subrc <> 0.
      append initial line to query_parameters assigning <query_parameter>.
      <query_parameter>-name = name.
    endif.

    <query_parameter>-value = value.
  endmethod.

  method set_header.
    read table headers
      assigning field-symbol(<header>)
      with key name = name.

    if sy-subrc <> 0.
      append initial line to headers assigning <header>.
      <header>-name = name.
    endif.

    <header>-value = value.

    read table header_names
      assigning field-symbol(<header_name>)
      with key name = name.

    if sy-subrc <> 0.
      append initial line to header_names assigning <header_name>.
      <header_name>-name = name.
    endif.
  endmethod.

  method execute.
    try.
        data(host) = |lambda.{ me->region }.amazonaws.com|.
        data(endpoint) = |https://{ host }/2015-03-31/functions/{ function_name }/invocations|.

        data(payload_hash) = zaws_sigv4_utilities=>get_hash( message = payload ).

        zaws_sigv4_utilities=>get_current_timestamp( importing amz_date  = data(amzdate)
                                                               datestamp = data(date_stamp) ).

        data(canonical_headers) = zaws_sigv4_utilities=>get_canonical_headers( value #(
          base headers
          ( name = 'host' value = host )
          ( name = 'x-amz-date' value = amzdate )
        ) ).

        data(signed_headers) = zaws_sigv4_utilities=>get_signed_headers( value #(
          base header_names
          ( name = 'host' )
          ( name = 'x-amz-date' )
        ) ).

        data(canonical_querystring) = zaws_sigv4_utilities=>get_canonical_querystring( query_parameters ).

        data(canonical_request) = zaws_sigv4_utilities=>get_canonical_request(
          http_method           = 'POST'
          canonical_uri         = |/2015-03-31/functions/{ function_name }/invocations|
          canonical_querystring = canonical_querystring
          canonical_headers     = canonical_headers
          signed_headers        = signed_headers
          payload_hash          = payload_hash ).

        data(algorithm) = zaws_sigv4_utilities=>get_algorithm( ).

        data(credential_scope) = zaws_sigv4_utilities=>get_credential_scope( datestamp = date_stamp
                                                                             region    = region
                                                                             service   = 'lambda' ).

        data(string_to_sign) = zaws_sigv4_utilities=>get_string_to_sign(
          algorithm         = algorithm
          amz_date          = amzdate
          credential_scope  = credential_scope
          canonical_request = canonical_request ).

        data(signing_key) = zaws_sigv4_utilities=>get_signature_key( key          = secret_key
                                                                     datestamp    = date_stamp
                                                                     region_name  = region
                                                                     service_name = 'lambda' ).

        data(signature) = zaws_sigv4_utilities=>get_signature( signing_key    = signing_key
                                                               string_to_sign = string_to_sign ).

        data(credential) = zaws_sigv4_utilities=>get_credential( access_key       = access_key
                                                                 credential_scope = credential_scope ).

        data(authorization_header) = zaws_sigv4_utilities=>get_authorization_header(
          algorithm      = algorithm
          credential     = credential
          signature      = signature
          signed_headers = signed_headers ).

        cl_http_client=>create_by_url(
          exporting
            url    = |{ endpoint }?{ canonical_querystring }|
          importing
            client = data(http_client) ).

        data(rest_client) = new cl_rest_http_client( io_http_client = http_client ).

        rest_client->if_rest_client~set_request_headers( corresponding #( headers ) ).
        rest_client->if_rest_client~set_request_header( iv_name = 'host' iv_value = host ).
        rest_client->if_rest_client~set_request_header( iv_name = 'x-amz-date' iv_value = amzdate ).
        rest_client->if_rest_client~set_request_header( iv_name = 'Authorization' iv_value = authorization_header ).

        data(request) = rest_client->if_rest_client~create_request_entity( ).
        request->set_binary_data( cl_abap_hmac=>string_to_xstring( payload ) ).

        rest_client->if_rest_client~post( request ).
        data(response) = rest_client->if_rest_client~get_response_entity( ).
        data(result_headers) = response->get_header_fields( ).
        result = response->get_string_data( ).

      catch cx_root into data(x_root).
        "Do something!!!
    endtry.
  endmethod.

  method if_oo_adt_classrun~main.
    data(lo_lambda) = new zaws_lmb_invoke( ).
    lo_lambda->set_access_key( '' ).
    lo_lambda->set_secret_key( '' ).
    lo_lambda->set_region( 'us-east-1' ).

    lo_lambda->set_function_name( `tmTestFunc001` ).

    lo_lambda->execute( importing result = data(result) ).
    out->write( result ).

  endmethod.

endclass.
