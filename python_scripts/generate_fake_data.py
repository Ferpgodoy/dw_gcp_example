import random
from faker import Faker
from datetime import datetime, timedelta
import uuid

fake = Faker('en_US')

def generate_sales(date_str, count=100):
    base_date = datetime.strptime(date_str, "%Y-%m-%d")
    sales = []

    product_names = ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Printer', 'Headset', 'Webcam', 'Tablet', 'Charger', 'Smartphone']
    product_categories = ['Electronics', 'Accessories', 'Peripherals']
    brands = ['Acme', 'Globex', 'Soylent', 'Initech', 'Umbrella']
    payment_methods = ['Credit Card', 'Debit Card', 'Cash', 'Bank Transfer', 'PayPal', 'Apple Pay']
    statuses = ['Completed', 'Pending', 'Cancelled', 'Refunded']
    channels = ['Online', 'Store', 'Phone']
    currencies = ['USD', 'EUR', 'GBP']
    devices = ['Mobile', 'Desktop', 'Tablet']
    shipping_methods = ['Standard', 'Express', 'Same-Day']
    referral_sources = ['Google', 'Facebook', 'Direct', 'Email', 'Instagram', 'Referral']
    campaigns = ['Spring Sale', 'Black Friday', 'Summer Promo', 'Cyber Monday', None, None]  # some with None

    for _ in range(count):
        # Date and time of sale
        time_offset = timedelta(
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        datetime_of_sale = base_date + time_offset

        # Product info
        product_name = random.choice(product_names)
        product = {
            "product_id": str(uuid.uuid4()),
            "name": product_name,
            "category": random.choice(product_categories),
            "brand": random.choice(brands),
            "sku": fake.bothify(text='???-#####'),
            "warranty_years": random.choice([1, 2, 3])
        }

        # Customer info
        customer = {
            "customer_id": str(uuid.uuid4()),
            "name": fake.name(),
            "gender": random.choice(['Male', 'Female', 'Other']),
            "birth_date": fake.date_of_birth(minimum_age=18, maximum_age=80).strftime("%Y-%m-%d"),
            "email": fake.email() if random.random() > 0.1 else None,
            "phone": fake.phone_number() if random.random() > 0.2 else None,
            "loyalty_points": random.randint(0, 5000)
        }

        # Sales rep (optional)
        sales_rep = None
        if random.random() > 0.3:
            sales_rep = {
                "sales_rep_id": str(uuid.uuid4()),
                "name": fake.name()
            }

        # Shipping (optional)
        shipping = None
        if random.random() > 0.15:
            shipping = {
                "address": fake.address(),
                "city": fake.city(),
                "state": fake.state_abbr(),
                "zip_code": fake.zipcode(),
                "country": fake.country(),
                "shipping_method": random.choice(shipping_methods),
                "shipping_cost": round(random.uniform(5.0, 50.0), 2)
            }

        quantity = random.randint(1, 10)
        unit_price = round(random.uniform(20.0, 2000.0), 2)
        discount_percent = random.choice([0, 5, 10, 15, 20, None])

        # Calculate total
        total = quantity * unit_price
        if discount_percent is not None:
            total *= (1 - discount_percent / 100)

        sale = {
            "sale_id": str(uuid.uuid4()),
            "datetime": datetime_of_sale.strftime("%Y-%m-%d %H:%M:%S"),
            "customer": customer,
            "product": product,
            "sales_rep": sales_rep,
            "shipping": shipping,
            "quantity": quantity,
            "unit_price": unit_price,
            "discount_percent": discount_percent,
            "payment_method": random.choice(payment_methods),
            "status": random.choice(statuses),
            "is_first_purchase": random.choice([True, False]),
            "total_price": round(total, 2),
            "channel": random.choice(channels),
            "currency": random.choice(currencies),
            "device_type": random.choice(devices),
            "campaign": random.choice(campaigns),
            "referral_source": random.choice(referral_sources)
        }

        sales.append(sale)

    return sales

def generate_product_reviews(date_str, count=100):
    base_date = datetime.strptime(date_str, "%Y-%m-%d")

    ratings = [1, 2, 3, 4, 5]
    review_titles = [
        "Excellent product", "Not what I expected", "Value for money", "Highly recommend", 
        "Could be better", "Will buy again", "Terrible experience", "Just okay", "Loved it", "Disappointed"
    ]
    reviews = []

    for _ in range(count):        
        time_offset = timedelta(
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        datetime_of_sale = base_date + time_offset
        review = {
            "review_id": str(uuid.uuid4()),
            "customer_id": str(uuid.uuid4()),
            "product_id": str(uuid.uuid4()),
            "rating": random.choice(ratings),
            "review_title": random.choice(review_titles),
            "review_text": fake.paragraph(nb_sentences=3),
            "review_date_time": datetime_of_sale.strftime("%Y-%m-%d %H:%M:%S"),
            "verified_purchase": random.choice([True, False])
        }
        reviews.append(review)

    return reviews


def generate_site_sessions(date_str, count=100):
    base_date = datetime.strptime(date_str, "%Y-%m-%d")

    referral_sources = ['Google', 'Facebook', 'Direct', 'Email', 'Instagram', 'Referral']
    device_types = ['Mobile', 'Desktop', 'Tablet']

    sessions = []

    for _ in range(count):
        time_offset = timedelta(
            hours=random.randint(0, 21),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        start_time = base_date + time_offset
        duration_minutes = random.randint(1, 120)
        end_time = start_time + timedelta(minutes=duration_minutes)
        session = {
            "session_id": str(uuid.uuid4()),
            "customer_id": str(uuid.uuid4()),
            "start_time": start_time.strftime("%Y-%m-%d %H:%M:%S"),
            "end_time": end_time.strftime("%Y-%m-%d %H:%M:%S"),
            "device_type": random.choice(device_types),
            "referral_source": random.choice(referral_sources),
            "pages_viewed": random.randint(1, 20),
            "converted": random.choice([True, False])
        }
        sessions.append(session)

    return sessions