# ABAP SQL CONSOLE
ABAP SQL edit and display,Migrate From Eclipse ADT SQL console, Based on Class CL_ADT_DP_OPEN_SQL_HANDLER
# Installation guide
   you can use abapgit to install it directly,
   otherwise you can copy the source code, then you need a custom screen( example 100) with a container named 'SQL', 
   also you need a status contanin all the function code( example BACK/RUN/CLS).
# Example source code
example 1
<pre><code>
select *  from tj02t
</code></pre>
example 2
<pre><code>
SELECT 
   ZABAPGIT~TYPE, 
   ZABAPGIT~VALUE, 
   ZABAPGIT~DATA_STR
 FROM 
  ZABAPGIT
</code></pre>
