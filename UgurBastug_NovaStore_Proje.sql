-- ============================================
-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- ============================================


-- ============================================
-- BÖLÜM 1: TABLO OLUŞTURMA (DDL)
-- ============================================

-- Tablo: categories
CREATE TABLE categories
(
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

-- Tablo: customers
CREATE TABLE customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR
(50) NOT NULL,
    city VARCHAR
(20),
    email VARCHAR
(100) UNIQUE
);

-- Tablo: products
CREATE TABLE products
(
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT REFERENCES categories (category_id)
);

-- Tablo: orders
CREATE TABLE orders
(
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers (customer_id),
    order_date TIMESTAMP
    WITH TIME ZONE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL
    (10,2) NOT NULL
);

    -- Tablo: order_details
    CREATE TABLE order_details
    (
        detail_id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders (order_id),
        product_id INT REFERENCES products (product_id),
        quantity INT NOT NULL DEFAULT 1
    );


    -- ============================================
    -- BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
    -- ============================================

    -- Kategoriler
    INSERT INTO categories
        (category_name)
    VALUES
        ('Electronics'),
        ('Clothing'),
        ('Books'),
        ('Cosmetics'),
        ('House and Living');

    -- Müşteriler
    INSERT INTO customers
        (full_name, city, email)
    VALUES
        ('Ahmet Yılmaz', 'Istanbul', 'ahmet.yilmaz@email.com'),
        ('Ayşe Kaya', 'Ankara', 'ayse.kaya@email.com'),
        ('Mehmet Demir', 'Izmir', 'mehmet.demir@email.com'),
        ('Fatma Şahin', 'Bursa', 'fatma.sahin@email.com'),
        ('Ali Çelik', 'Gebze', 'ali.celik@email.com'),
        ('Zeynep Arslan', 'Istanbul', 'zeynep.arslan@email.com'),
        ('Mustafa Koç', 'Ankara', 'mustafa.koc@email.com');

    -- Ürünler
    INSERT INTO products
        (product_name, price, stock, category_id)
    VALUES
        ('Wireless Headphones', 899.99, 50, 1),
        ('Mechanical Keyboard', 1249.99, 30, 1),
        ('USB-C Hub', 349.99, 75, 1),
        ('Slim Fit Jeans', 459.99, 100, 2),
        ('Cotton T-Shirt', 149.99, 200, 2),
        ('Running Jacket', 699.99, 45, 2),
        ('Face Moisturizer', 299.99, 80, 4),
        ('Lipstick Set', 189.99, 120, 4),
        ('Coffee Maker', 1599.99, 15, 5),
        ('Cast Iron Pan', 849.99, 30, 5),
        ('Yoga Mat', 399.99, 60, 2),
        ('Dumbbell Set', 1899.99, 10, 1),
        ('Tuesdays with Mori', 39.99, 100, 3),
        ('Sapiens', 39.99, 50, 3),
        ('Hitchhiker''s Guide to the Galaxy', 39.99, 0, 3);

    -- Siparişler
    INSERT INTO orders
        (customer_id, order_date, total_amount)
    VALUES
        (1, '2024-01-05', 2149.97),
        (2, '2024-01-12', 459.99),
        (3, '2024-02-03', 1249.99),
        (4, '2024-02-14', 1949.98),
        (5, '2024-03-01', 619.98),
        (6, '2024-03-18', 3199.98),
        (7, '2024-04-02', 299.99),
        (1, '2024-04-15', 849.99),
        (3, '2024-05-10', 1899.99),
        (5, '2024-05-22', 969.98);

    -- Sipariş Detayları
    INSERT INTO order_details
        (order_id, product_id, quantity)
    VALUES
        (1, 1, 1),
        (1, 2, 1),
        (2, 4, 1),
        (3, 2, 1),
        (4, 6, 1),
        (4, 5, 2),
        (5, 11, 1),
        (5, 8, 1),
        (6, 9, 2),
        (7, 7, 1),
        (8, 10, 1),
        (9, 12, 1),
        (10, 3, 1),
        (10, 13, 1),
        (10, 14, 1);


    -- ============================================
    -- BÖLÜM 3: SORGULAMA VE ANALİZ (DQL)
    -- ============================================

    -- Sorgu 1: Stok miktarı 20'den az olan ürünler (azalan sıraya göre)
    SELECT product_name, stock
    FROM products
    WHERE stock < 20
    ORDER BY stock DESC;

    -- Sorgu 2: Hangi müşteri hangi tarihte sipariş vermiş
    SELECT full_name, city, order_date, total_amount
    FROM customers
        INNER JOIN orders ON customers.customer_id = orders.customer_id;

    -- Sorgu 3: Ahmet Yilmaz isimli musterinin aldigi urunlerin isimleri fiyatlari ve kategorileri
    SELECT full_name, product_name, price, category_name
    from products JOIN categories ON categories.category_id = products.category_id
        JOIN order_details ON products.product_id = order_details.product_id
        JOIN orders ON order_details.order_id = orders.order_id
        JOIN customers ON orders.customer_id = customers.customer_id
    WHERE full_name = 'Ahmet Yılmaz';

    -- Sorgu 4: Hangi kategoride toplam kac adet urun var
    SELECT categories.category_name, SUM(stock)
    FROM products JOIN categories ON categories.category_id = products.category_id
    GROUP BY categories.category_name;

    -- Sorgu 5: Her musterinin sirkete kazandirdigi toplam ciro
    SELECT full_name, SUM(total_amount) AS total_spent
    FROM customers JOIN orders ON customers.customer_id = orders.customer_id
    GROUP BY customers.full_name
    ORDER BY total_spent desc;

    -- Sorgu 6: Bugunun tarihine gore siparislerin uzerinden kac gun gecti
    SELECT order_date, CURRENT_DATE, CURRENT_DATE - order_date AS days_since_order
    FROM orders;


    -- ============================================
    -- BÖLÜM 4: Ileri seviye Veri Tabani Nesneleri
    -- ============================================

    -- Sorgu 1 Sürekli uzun JOIN sorguları yazmamak için; Müşteri Adı, Sipariş Tarihi, Ürün Adı ve Adet bilgilerini tek bir tablodaymış gibi getiren vw_SiparisOzet isminde bir VIEW oluşturun
    CREATE VIEW vw_OrderSummary
    AS
        SELECT full_name, order_date, product_name, quantity
        FROM customers
            JOIN orders ON customers.customer_id = orders.customer_id
            JOIN order_details ON order_details.order_id = orders.order_id
            JOIN products ON products.product_id = order_details.product_id;

-- Sorgu 2 Backup

-- T-SQL yerine PostgreSQL kullanilmistir, bu yuzden pg_dump komutuyla .sql dosyasi istenilen yere kopyalanabilir: pg_dump -U kullanici_adi -d NovaStoreDB -f /path/to/backup/novastore_backup.sql
-- Ayrica Linux serverinde cronjob kullanilarak bu projenin her gun otomatik olarak yedegi alinmaktadir: 0 0 * * * ./novastoredb_backup_script.sh (buradaki shell script ozel bir yedekleme scriptidir)

-- novastoredb_backup_script.sh
-- #!/bin/bash
-- FILE="novastore_backup_$(date +%Y%m%d_%H%M%S).sql"
-- /usr/bin/pg_dump novastoredb > /home/user/novastorebackupdir/$FILE && scp /home/user/novastorebackupdir/$FILE ugur@192.168.1.x:C:/path/to/backup/file




































