Plot correlation matrix as a schemaball.

### Examples

    schemaball
    
![](https://github.com/okomarov/schemaball/blob/master/fig/ex01.png)

Use your own correlation matrix (only lower off-diagonal triangular part is considered)
```
x = rand(10).^3;
x(:,3) = 1.3*mean(x,2);
schemaball(x)
```

Use custom labels as ['aa'; 'bb'; 'cc'; ...] or {'Hi','how','are',...}
```
schemaball(x, repmat(('a':'j')',1,2))
schemaball(x, {'Hi','how','is','your','day?', 'Do','you','like','schemaballs?','NO!!'})
```

Customize line or node colors

    schemaball([],[],[1,0,1;1 1 0])
    schemaball([],[],[],[0,1,0])

Customize other properties
```
h = schemaball;
set(h.l(~isnan(h.l)), 'LineWidth',1.2)
set(h.s, 'MarkerEdgeColor','red','LineWidth',2,'SizeData',100)
set(h.t, 'EdgeColor','white','LineWidth',1)
```

![](https://github.com/okomarov/schemaball/blob/master/fig/ex07.png)
