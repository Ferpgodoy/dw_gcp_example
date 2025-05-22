import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker('en_US')

def generate_sales(date_str, count=1000):
    base_date = datetime.strptime(date_str, "%Y-%m-%d")
    sales = []

    product_list = ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Printer', 'Headset', 'Webcam', 'Tablet', 'Charger', 'Smartphone']
    payment_methods = ['Credit Card', 'Debit Card', 'Cash', 'Bank Transfer', 'PayPal', 'Apple Pay']
    statuses = ['Completed', 'Pending', 'Cancelled', 'Refunded']

    for _ in range(count):
        time_offset = timedelta(
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        datetime_of_sale = base_date + time_offset

        sale = {
            "sale_id": fake.uuid4(),
            "datetime": datetime_of_sale.strftime("%Y-%m-%d %H:%M:%S"),
            "customer_name": fake.name(),
            "customer_email": fake.email() if random.random() > 0.1 else None,  # 10% chance to be missing
            "customer_phone": fake.phone_number() if random.random() > 0.2 else None,  # 20% chance to be missing
            "product": random.choice(product_list),
            "product_category": random.choice(['Electronics', 'Accessories', 'Peripherals']),
            "product_sku": fake.bothify(text='???-#####'),
            "quantity": random.randint(1, 10),
            "unit_price": round(random.uniform(20.0, 2000.0), 2),
            "discount_percent": random.choice([0, 5, 10, 15, 20, None]),
            "payment_method": random.choice(payment_methods),
            "status": random.choice(statuses),
            "shipping_address": fake.address() if random.random() > 0.15 else None,  # 15% chance to be missing
            "city": fake.city(),
            "state": fake.state_abbr(),
            "zip_code": fake.zipcode(),
            "country": fake.country(),
            "is_first_purchase": random.choice([True, False]),
            "sales_rep": fake.name() if random.random() > 0.3 else None  # 30% chance to be missing
        }

        # Calculate total price with optional discount
        total = sale["quantity"] * sale["unit_price"]
        if sale["discount_percent"] is not None:
            total *= (1 - sale["discount_percent"] / 100)
        sale["total_price"] = round(total, 2)

        sales.append(sale)

    return sales