# ZSQL_CONSOLE
ABAP SQL select and display
Migrate From Eclipse ADT SQL console, Based on Class CL_ADT_DP_OPEN_SQL_HANDLER
# Example source code
example 1
<pre><code>
select *
  from tj02t
  into table @data(lt_alv)
  up to 10 rows.
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
