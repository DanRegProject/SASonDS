


/* can close the first 30 viewtables */

%macro closevts;
	%do i=1 %to 30;
			dm 'next VIEWTABLE:; end;';
	%end;
%mend;

%closevts;

