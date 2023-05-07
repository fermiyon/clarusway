import streamlit as st
import pickle
import pandas as pd
import locale
from sklearn.compose import make_column_transformer
from sklearn.preprocessing import OrdinalEncoder
from babel.numbers import format_currency


st.set_page_config(page_title="Car Price Prediction", page_icon=":car:")
st.sidebar.title('Car Price Prediction')

car_model=st.sidebar.selectbox("Select model of your car", ('Audi A1', 'Audi A3', 'Opel Astra', 'Opel Corsa', 'Opel Insignia', 'Renault Clio', 'Renault Duster', 'Renault Espace'))
age=st.sidebar.selectbox("What is the age of your car?",(0,1,2,3))
hp=st.sidebar.slider("What is the hp_kw of your car?", 40, 300, step=1)
km=st.sidebar.slider("What is the km of your car?", 0,350000, step=1000)
gearing_type=st.sidebar.radio('Select gear type',('Automatic','Manual','Semi-automatic'))

placeholder = st.empty()

with placeholder.container():
    st.header(':red[Get a Car Price Prediction in Seconds. :rocket:]')
    st.divider()
    st.markdown("""
                Unlock the true value of your car with just a few clicks! 
                
                Enter your car information in the sidebar and discover its worth based on current market trends. 
                
                Our advanced algorithms will analyze your data and provide you with an estimate in seconds. 
                
                Whether you're buying, selling, or just curious, our car price prediction app can provide the information you need to make informed decisions. 
                
                Try it out now and discover the value of your car!
                """)

model=pickle.load(open("cat_model","rb"))

my_dict = {
    "hp_kW": hp,
    "age": age,
    "make_model": car_model,
    "km": km,
    "Gearing_Type":gearing_type
}

df = pd.DataFrame.from_dict([my_dict])


if st.sidebar.button("Predict", type='primary', use_container_width=True):
    placeholder.empty()
    prediction = model.predict(df)

    price = format_currency(int(prediction[0]), 'EUR', locale='de_DE') # Format the prediction value as a Euro currency with the euro symbol
    st.header(':red[{}]'.format(price))

    st.markdown(f"Based on the information you provided, your **{car_model}** has a horsepower of **{hp}** and is **{age}** year old. It has been driven for a total of **{km}** km and has an **{gearing_type}** gearing type. Our analysis suggests that your car is worth an estimated **{price}.**")
    #st.table(df)
    st.divider()
    with st.expander("More information"):
        st.caption("""
            At the heart of our car price prediction app is a powerful machine learning model called CatBoost Regressor. 

            When you enter information about your car, such as the model, age, mileage, and other factors, our algorithm uses this information to make a prediction about the value of your car based on these factors.

            It's important to keep in mind that there is always a margin of error when making predictions, and our model may be off by up to 10%. (R2 score is 0.92)

            We're confident that our model will provide you with a good estimate of your car's value, but it's always a good idea to consult with a professional appraiser or do additional research to get a more accurate estimate. Nonetheless, we're always working to improve our algorithm and provide the best possible predictions for our users.
            """)