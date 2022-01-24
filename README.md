# Reedsy Challenge - Reedsy's (fictional) Merchandising Store

- Author:
  - Name: Alberto Hernández Cerezo
  - E-Mail: pascu216@gmail.com
  - LinkedIn: https://www.linkedin.com/in/alberto-hern%C3%A1ndez-cerezo-006a20b4/
  - CV: You can find it in the repository (Aberto CV.pdf)
- About Me:

Hi! I am Alberto Hernández, Software Engineer, Full Stack Developer & Entrepreneur. Spanish living in Leipzig, Germany. In winter, you can find me hidden from the cold at home, binge-watching series, playing video games and board games with friends, or just chilling with a book. In the summer, I stay away from home, enjoying walks at the lake, biking, doing bouldering, and any other sort of outdoor activity. And no matter the time of the year, I always book the time to cook, go to the gym and work on my ideas. One of them is mysenii, and for me, it represents my most outstanding achievement so far: the conceptualization, implementation, and validation with real customers and medical institutions of an idea that aims to impact society positively: make mental health accessible for everyone.

I am a Software Engineer and Full Stack Developer with more than five years of experience. I started as FrontEnd & BackEnd developer for a media company in Berlin, developing multiple internal tools for managing its media content database. In 2017 I joined DOCYET, a newly founded digital healthcare startup. With a small team of three members, my challenge was to set its software infrastructure and pack its unique bot technology in software applications that could be distributed as a product to customers. Conforming the team growth responsibilities switched. I set part of my developer role aside to lead and instruct the new IT members in the company and support legal and medical departments adapting our products to the data privacy and medical certifications required for them to go live. Now DOCYET counts with more than 20 employees and different products integrated with many of the biggest healthcare insurances in the market. Before this, I also did small jobs as a freelance, and I worked in research, specializing in AI and Automated Diagnoses, publishing some papers.

## Challenge Solution

### Installation Instructions

#### Pre-requisites:

- Install Docker and Docker Compose.

#### Installation Steps:

1. Clone project repository: https://gitlab.com/Pascu/reedsy-challenge-alberto-hernandez-cerezo
2. Go to the project folder.
3. Run docker-compose -f docker-compose-production.yml up.
  - The application will be running in port 3000.
4. If you want to skip the installation, the project is also deployed in: https://aqueous-chamber-49175.herokuapp.com

#### API Documentation

- **Online API documentation:**
  1. Launch Rails application.
  2. Go to http://localhost:3000/apipie.
  3. You can also find it here.
  

- **Swagger API documentation:**
  - In the repository folder, you can find a swagger.yml file copy-pasted in the Swagger Editor.
  - Swagger formats array parameters as a string that concatenates their elements with commas. This format is incompatible with Rails array parameters. Thus, basket/check API endpoint does not work via swagger. Please use postman, curl, or other alternatives to test the basket/check endpoint.


- **Postman API Requests Collection:**
  - In the repository folder, you can find the Reedsy.postman_collection.json file. It contains a collection of API requests to display the results of the multiple requests that answer the different proposed challenges. You can use postman to import the file and perform the requests.

### Test Coverage & Linter

The challenge repository is configured with automated pipelines to generate rspec test and Rubocop linter reports. You can consult them in:

- Rubocop linter report: https://pascu.gitlab.io/reedsy-challenge-alberto-hernandez-cerezo/linter/index.html
- Rspec test coverage report: https://pascu.gitlab.io/reedsy-challenge-alberto-hernandez-cerezo/tests/index.html#_AllFiles

### Challenges Solution

Based on the challenge description, these were the constraints I imposed myself to complete the challenge:

1. Comply with all minimal requirements: provide the simplest solution to all challenges to claim its completion.
2. Develop a maintainable and scalable solution for the challenge: design solution not as a set of answers for each challenge but as a maintainable and scalable project, using proper code quality standards and project configurations (test coverage, linter, changelog, etc.).
3. Time restriction: complete the challenge with a two-week deadline restriction and a limited number of hours to work on the challenge per week. This helped me prioritize tasks and delimitate the scope of my solution.

The solutions proposed for each challenge were:

- **Challenge I:**
  Delivering a collection of models can be done with Rails scaffold commands. To provide more flexibility in the product listing, I added pagination, sorting, and filtering options and logic to allow switching between currencies. Filtering and sorting options were last-day additions, limiting them to name and code attributes and not having proper test coverage.
- **Challenge II:**
  Logic to update models is also generated via Rails scaffold commands. I extended that logic to update the prices, allowing price updates with different currencies. I defined validators for the price and available currencies and implemented the update logic to integrate it within the Product model update method.
- **Challenge III:**
  To calculate the price of a list of products, I created a set of non-persistent models: Basket, BasketItem and BasketDiscount. Via a class method, baskets are instantiated from an array of products, and prices are calculated via the sum of all basket items.
- **Challenge IV:**
  The goal is to calculate the optimal set of discounts applicable to a basket, with the restriction of each discount only being applied once. To solve the problem, I used an algorithm to build a decision tree with all possible discount combinations per basket, which looks for the cheapest decision branch via recursion.

Complementary tasks performed for the completion of the challenges were:

- **Unit test coverage for models & Integration test coverage for controllers**, to comply with code quality standards and secure the correct functioning of the software. To adjust to the deadline, the less relevant tests, such as unit
tests for controllers and helpers, and tests for last-day sort and filter features, were discarded.
- **Set up automated test and linter pipelines** to check all tests are passing and code complies with project code styling.
- **Automated deployment pipeline**, hosting application in Heroku.

Potential improvements I would consider are:

- **Security**: there were no security measures implemented, such as CORS configuration, securing the project keys out of the repository, and so on. In a real scenario, these elements should be managed appropriately.
- **Documentation**: classes and methods are commented in detail, but no pipeline for generating html docs was implemented. Using a static type checker, as Sorbet, was also considered an alternative to having so much documentation.
- **Profiler**: having a profiler is always a good way to check the performance of your software and discover potential improvements.
