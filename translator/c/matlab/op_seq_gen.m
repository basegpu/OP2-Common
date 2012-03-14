%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
% This MATLAB routine generates the header file op_seq.h                %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function op_seq_gen()

%
% this sets the max number of arguments in op_par_loop
%

maxargs = 10;

%
% first the top bit
%

file = strvcat(...
'//                                                                 ',...
'// header for sequential and MPI+sequentional execution            ',...
'//                                                                 ',...
'                                                                   ',...
'#include "op_lib_core.h"                                           ',...
'                                                                   ',...
'inline void op_arg_set(int n, op_arg arg, char **p_arg, int halo){ ',...
'  *p_arg = arg.data;                                               ',...
'                                                                   ',...
'  if (arg.argtype==OP_ARG_GBL) {                                  ',...
'    if (halo && (arg.acc != OP_READ)) *p_arg = NULL;              ',...
'  }                                                                ',...
'  else {                                                           ',...
'    if (arg.map==NULL)         // identity mapping                 ',...
'      *p_arg += arg.size*n;                                        ',...
'    else                       // standard pointers                ',...
'      *p_arg += arg.size*arg.map->map[arg.idx+n*arg.map->dim];     ',...
'  }                                                                ',...
'}                                                                  ',...
'                                                                   ',...
'inline void op_args_set(int iter, int nargs, op_arg *args,                   ',...
'                        char **p_a, int halo){                     ',...
'  for (int n=0; n<nargs; n++)                                      ',...
'    op_arg_set(iter, args[n], &p_a[n], halo);                         ',...
'}                                                                  ',...
'                                                                   ',...
'inline void op_args_check(op_set set, int nargs, op_arg *args,     ',...
'                                      int *ninds, const char *name) {    ',...
'  for (int n=0; n<nargs; n++)                                      ',...
'    op_arg_check(set,n,args[n],ninds,name);                         ',...
'}                                                                  ',...
'                                                                   ');

%
% now for op_par_loop defns
%

for nargs = 1:maxargs
  c_nargs = num2str(nargs);


  file = strvcat(file,' ', ...
    '// ',...
   ['// op_par_loop routine for ' c_nargs ' arguments '],...
    '// ',' ');

  n_per_line = 4;

  line = 'template < ';
  for n = 1:nargs
    line = [ line 'class T' num2str(n-1) ','];
    if (n==nargs)
      line = [line(1:end-1) ' >'];
    end
    if (mod(n,n_per_line)==0 || n==nargs)
      file = strvcat(file,line);
      line = '           ';
    elseif (n<=10)
      line = [line ' '];
    end
  end

  line = 'void op_par_loop(void (*kernel)( ';
  for n = 1:nargs
    line = [ line 'T' num2str(n-1) '*,'];
    if (n==nargs)
      line = [line(1:end-1) ' ),'];
    end
    if (mod(n,n_per_line)==0 || n==nargs)
      file = strvcat(file,line);
      line = '                                 ';
    elseif (n<=10)
      line = [line ' '];
    end
  end

  file = strvcat(file,'    char const * name, op_set set,');

  line = '    ';
  for n = 1:nargs
    line = [ line 'op_arg arg' num2str(n-1) ','];
    if (n==nargs)
      line = [line(1:end-1) ' ) {'];
    end
    if (mod(n,n_per_line)==0 || n==nargs)
      file = strvcat(file,line);
      line = '    ';
    elseif (n<=10)
      line = [line ' '];
    end
  end

  file = strvcat(file,' ', ['  char  *p_a[' c_nargs ']; ']);

  line = ['  op_arg args[' c_nargs '] = { '];

  for n = 1:nargs
    line = [ line 'arg' num2str(n-1) ',' ];
    if (n==nargs)
      line = [line(1:end-1) ' };'];
    end
    if (mod(n,n_per_line)==0 || n==nargs)
      file = strvcat(file,line);
      line = '                      ';
    elseif (n<=10)
      line = [line ' '];
    end
  end

%
% diagnostics and start of main loop
%

  file = strvcat(file,...
    '                                                                  ',...
    '  // consistency checks                                           ',...
    '                                                                  ',...
    '  int ninds = 0;                                                  ',...
    '                                                                  ',...
   ['  if (OP_diags>0) op_args_check(set,' c_nargs ',args,&ninds,name);'],...
    '                                                                  ',...
    '  if (OP_diags>2) {                                               ',...
    '    if (ninds==0)                                                 ',...
    '      printf(" kernel routine w/o indirection:  %s \n",name);     ',...
    '    else                                                          ',...
    '      printf(" kernel routine with indirection: %s \n",name);     ',...
    '  }                                                               ',...
    '                                                                  ',...
    '  // initialise timers',...
    '  double cpu_t1, cpu_t2, wall_t1, wall_t2;',...
    '  op_timers(&cpu_t1, &wall_t1); ',...
    '                                                                  ',...
    '  // MPI halo exchange and dirty bit setting, if needed           ',...
    '                                                                  ',...
   ['  int n_upper = op_mpi_halo_exchanges(set, ' c_nargs ',args);                         '],...
    '                                                                  ',...
    '  // loop over set elements                                       ',...
    '                                                                  ',...
    '  int halo = 0;                                               ',...
    '                                                                  ',...
    '  for (int n=0; n<n_upper; n++) {                                 ',...
   ['    if (n==set->core_size) op_mpi_wait_all(' c_nargs ',args);          '],...
    '    if (n==set->size) halo = 1;                               ',...
    '                                                                  ',...
   ['    op_args_set(n,' c_nargs ',args,p_a,halo);                     '],...
    '                                                                  ',...
    '    // call kernel function, passing in pointers to data          ',...
    ' ');

%
% call to user's kernel
%

  line = ['    kernel( '];
  for n = 1:nargs
    line = [ line '(T' num2str(n-1) ' *)p_a['  num2str(n-1) '],'];
    if (n==nargs)
      line = [line(1:end-1) ' );'];
    end
    if (mod(n,n_per_line)==0 || n==nargs)
      file = strvcat(file,line);
      line = '            ';
    elseif (n<=10)
      line = [line '  '];
    end
  end

% file = strvcat(file,...
%     '  }                                                               ',...
%     '                                                                  ',...
%     '  // global reduction for MPI execution, if needed                ',...
%     '                                                                  ',...
%    ['  op_mpi_global_reduction(' c_nargs ',args);                      '],...
%     '  // update timer record',...
%     '  op_timers(&cpu_t2, &wall_t2); ',...
%     '  #if COMM_PERF',...
%     '  int k_i = op_mpi_perf_time(name, wall_t2 - wall_t1);',...
%     '  op_mpi_perf_comms(k_i, args);',...
%     '  #endif',...
%     '                                                                  ',...
%     '                                                                  ');

file = strvcat(file,...
    '  }                                                  ',' ',...
    '  // global reduction for MPI execution, if needed   ',' ');

  for n = 1:nargs
    file = strvcat(file,...
      [ '  if (arg' num2str(n-1) '.argtype==OP_ARG_GBL &&' ...
             ' arg' num2str(n-1) '.acc!=OP_READ) '         ]);
    file = strvcat(file,...
      [ '    op_mpi_reduce(arg' num2str(n-1) '.dim,'       ...
                           '(T' num2str(n-1) ' *)'         ...
                         'p_a[' num2str(n-1) ']);'         ]);
  end

  file = strvcat(file,...
      '  // update timer record',...
      '  op_timers(&cpu_t2, &wall_t2); ',...
      '  #if COMM_PERF',...
      '  int k_i = op_mpi_perf_time(name, wall_t2 - wall_t1);',...
      '  op_mpi_perf_comms(k_i, args);',...
      '  #endif',...
      '                                                                  ',...
      '                                                                  ');

  file = strvcat(file,'}',' ');
end

%
% print out into file
%


fid = fopen('op_seq.h','wt');
fprintf(fid,'// \n// auto-generated by op_seq_gen.m on %s \n//\n\n',datestr(now));
for n=1:size(file,1)
  fprintf(fid,'%s\n',file(n,:));
end
fclose(fid);

