-- ======================================================
-- 16_experiment_candidates.sql
-- Phase 2: Experiment Candidates
-- Goal: translate opportunity discovery into practical A/B test candidates.
-- ======================================================

DROP TABLE IF EXISTS experiment_candidates;

CREATE TABLE experiment_candidates (
    priority text,
    opportunity_area text,
    target_segment text,
    funnel_stage text,
    evidence text,
    problem_statement text,
    hypothesis text,
    proposed_experiment text,
    primary_metric text,
    secondary_metric text,
    guardrail_metric text,
    expected_uplift_range text
);


INSERT INTO experiment_candidates
VALUES
(
    'P1',
    'High-intent lost sessions',
    'Users who added 3-20 items to cart but did not purchase',
    'Checkout',
    '310,249 cleaned sessions; avg 7.12 cart items; avg 10.86 products interacted; avg 22.94 minutes in session',
    'A large group of users showed strong purchase intent but left before completing purchase.',
    'Users may need reassurance or a stronger reason to complete checkout once they have built a basket.',
    'Test checkout reassurance messaging, free-shipping messaging or abandoned-cart reminder prompts.',
    'Cart-to-purchase conversion rate',
    'Overall purchase conversion rate',
    'Average order value and return rate',
    '+3% to +5%'
),
(
    'P2',
    'High exploration lost sessions',
    'Users who viewed 7+ products but did not purchase',
    'Product discovery',
    '147,445 sessions; avg 13.27 products viewed; avg 7.38 cart items; avg 38.23 minutes in session',
    'Some users explore many products and spend meaningful time on site, but still fail to purchase.',
    'Users may be struggling to compare products, choose the right product or find enough confidence to buy.',
    'Test recommendation carousel, recently viewed products, product comparison support or review highlights.',
    'View-to-cart conversion rate',
    'Purchase conversion rate',
    'Session duration and bounce rate',
    '+2% to +4%'
),
(
    'P3',
    'Vacuum category cart abandonment',
    'appliances.environment.vacuum',
    'Cart to checkout',
    '87,248 view sessions; 12,410 cart sessions; 3,195 purchase sessions; 9,215 abandoned cart sessions; 74.25% cart abandonment',
    'Vacuum products show high cart intent but many users do not complete purchase.',
    'Delivery cost, delivery timing or checkout uncertainty may be discouraging users from completing purchase.',
    'Test delivery reassurance, free-delivery threshold messaging or checkout reassurance on product and cart pages.',
    'Cart-to-purchase conversion rate',
    'Revenue per session',
    'Average order value',
    '+3% to +5%'
),
(
    'P4',
    'High-price product friction',
    '£50+ products',
    'Pre-cart',
    '324,937 view sessions; 25,411 cart sessions; 6,184 purchase sessions; 7.82% view-to-cart rate; £101.76 revenue per purchase session',
    'High-priced products generate high revenue per purchase but users are much less likely to add them to cart.',
    'Users may need more trust, value reassurance or payment flexibility before adding expensive products to cart.',
    'Test product trust badges, delivery clarity, returns reassurance, payment reassurance or instalment messaging.',
    'View-to-cart conversion rate',
    'Purchase conversion rate',
    'Refund or return rate',
    '+2% to +4%'
),
(
    'P5',
    'Under £5 checkout friction',
    'Under £5 products',
    'Checkout',
    '2,126,666 view sessions; 696,183 cart sessions; 124,803 purchase sessions; 82.07% cart abandonment',
    'Low-priced products attract high traffic and cart activity but have weak cart-to-purchase completion.',
    'Users may abandon low-value baskets if delivery cost or checkout effort feels too high relative to basket value.',
    'Test free-shipping threshold, basket-building prompts, bundle offers or simplified checkout.',
    'Cart-to-purchase conversion rate',
    'Average basket value',
    'Margin per order',
    '+2% to +4%'
);


-- Review final experiment roadmap
SELECT *
FROM experiment_candidates
ORDER BY priority;