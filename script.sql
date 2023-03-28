-- CREATE DATABASE

CREATE DATABASE mystore;

-- CREATE TABLES

CREATE TABLE categorias ( id SERIAL PRIMARY KEY, nome VARCHAR(255) NOT NULL );

CREATE TABLE produtos ( id SERIAL PRIMARY KEY, nome VARCHAR(255) NOT NULL, descricao TEXT, preco NUMERIC(10,2) NOT NULL, id_categoria INTEGER NOT NULL, FOREIGN KEY (id_categoria) REFERENCES categorias(id) );

CREATE TABLE clientes ( id SERIAL PRIMARY KEY, nome VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL UNIQUE, telefone VARCHAR(20) );

CREATE TABLE pedidos ( id SERIAL PRIMARY KEY, id_cliente INTEGER NOT NULL, data_pedido DATE NOT NULL, endereco_entrega TEXT NOT NULL, FOREIGN KEY (id_cliente) REFERENCES clientes(id) );

CREATE TABLE itens_pedido ( id SERIAL PRIMARY KEY, id_produto INTEGER NOT NULL, id_pedido INTEGER NOT NULL, quantidade INTEGER NOT NULL, preco_unitario NUMERIC(10,2) NOT NULL, FOREIGN KEY (id_produto) REFERENCES produtos(id), FOREIGN KEY (id_pedido) REFERENCES pedidos(id) );

-- INSERT DATA FOR EACH COLUMN WITH 50 ROWS

INSERT INTO categorias (nome) SELECT 'Categoria ' || n FROM generate_series(1, 50) n;

INSERT INTO produtos (nome, descricao, preco, id_categoria) SELECT 'Produto ' || n, 'Descrição do produto ' || n, (n * 10)::numeric(10,2), (n % 50) + 1 FROM generate_series(1, 50) n;

INSERT INTO clientes (nome, email, telefone) SELECT 'Cliente ' || n, 'cliente' || n || '@bridge.com', '(00) 0000-000' || n FROM generate_series(1, 50) n;

INSERT INTO pedidos (id_cliente, data_pedido, endereco_entrega) SELECT (n % 50) + 1, current_date, 'Endereço de entrega ' || n FROM generate_series(1, 50) n;

INSERT INTO itens_pedido (id_produto, id_pedido, quantidade, preco_unitario)
SELECT (n % 50) + 1, (n % 50) + 1, n, (n * 10)::numeric(10,2)
FROM generate_series(1, 50) n;

--  Listar todos os produtos com nome, descrição e preço em ordem alfabética crescente;
SELECT nome, descricao, preco FROM produtos ORDER BY nome ASC;

-- Listar todas as categorias com nome e número de produtos associados, em ordem alfabética crescente;
SELECT c.nome, COUNT(p.id) as num_produtos FROM categorias c LEFT JOIN produtos p ON p.id_categoria = c.id GROUP BY c.id ORDER BY c.nome ASC;

-- Listar todos os pedidos com data, endereço de entrega e total do pedido (soma dos preços dos itens), em ordem decrescente de data:
SELECT p.id, p.data_pedido, p.endereco_entrega, SUM(ip.quantidade * ip.preco_unitario) as total_pedido FROM pedidos p LEFT JOIN itens_pedido ip ON ip.id_pedido = p.id GROUP BY p.id ORDER BY p.data_pedido DESC;

-- Listar todos os produtos que já foram vendidos em pelo menos um pedido, com nome, descrição, preço e quantidade total vendida, em ordem decrescente de quantidade total vendida:
SELECT p.nome, p.descricao, p.preco, SUM(ip.quantidade) as quantidade_total_vendida FROM produtos p INNER JOIN itens_pedido ip ON ip.id_produto = p.id GROUP BY p.id ORDER BY quantidade_total_vendida DESC;

-- Listar todos os pedidos feitos por um determinado cliente, filtrando-os por um determinado período, em ordem alfabética crescente do nome do cliente e ordem crescente da data do pedido:
SELECT c.nome as nome_cliente, p.id as id_pedido, p.data_pedido, p.endereco_entrega, SUM(ip.quantidade * ip.preco_unitario) as total_pedido FROM pedidos p LEFT JOIN itens_pedido ip ON ip.id_pedido = p.id LEFT JOIN clientes c ON c.id = p.id_cliente WHERE c.nome = 'Nome do cliente' AND p.data_pedido BETWEEN '2022-01-01' AND '2022-12-31' GROUP BY c.id, p.id ORDER BY c.nome ASC, p.data_pedido ASC;


-- Listar possíveis produtos com nome replicado e a quantidade de replicações, em ordem decrescente de quantidade de replicações:
SELECT nome, COUNT(*) as quantidade_de_replicas FROM produtos GROUP BY nome HAVING COUNT(*) > 1 ORDER BY quantidade_de_replicas DESC;