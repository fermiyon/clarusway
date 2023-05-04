import streamlit as st
import pandas as pd
import numpy as np
from PIL import Image

# Title
st.title("This is a title")
st.text("This is some text")

# Markdown
st.markdown('Streamlit is _really_ **cool**')
st.markdown('### This is third markdown')

# Success/info/error
st.success('This is a success message.')
st.info('This is info message.')
st.error('This is error')
st.warning('This is warning')
st.exception("NameError('Exception message')")

st.write('Hello World :sunglasses:')

#Image
img = Image.open('images.jpeg')
st.image(img, caption='kitty', width=300)

# Add video
# my_video = open('ml.mov','rb')
# st.video(my_video)

# Add youtube video
st.video('https://www.youtube.com/watch?v=E9iP8jdtYZ0')

# Checkbox
st.checkbox('Up and Down')
cbox  = st.checkbox('Hide and Seek')

if cbox:
    st.write('Hide')
else:
    st.write('seek')

# Add radio button
status = st.radio('Select a color',('blue','orange','yellow'))
st.write(f'My favourite color is {status}')

# Add button
st.button('Click me')

if st.button('Press me'):
    st.success('Analyze results are..')

occupation = st.selectbox('Occupation',('Programmer','Data Scientist'))
st.write(f'Your occupation is is {occupation}')

# Multi select
multi_select = st.multiselect('Select multiple numbers',[1,2,3,4,5])
st.write(f'You selected {len(multi_select)} number(s)')
st.write('Your selection is/are', multi_select)
for i in range(len(multi_select)):
    st.write(f'Your {i+1} selection is {multi_select[i]}')

# Slider
option1 = st.slider('Select a number', min_value=5,max_value=70,value=30, step = 5)
option2 = st.slider('Select a number', min_value=0.2,max_value=30.2,value=13.2, step = 0.2)

result = option1*option2
st.write('The result is', result)

# Text Input
name = st.text_input('Enter your name:', placeholder='Your name here')

if st.button('Submit'):
    st.write(f'Hello {name.title()}')

# Code gorunumu
st.code('import pandas as pd')

# Echo
with st.echo():
    import pandas as pd
    import numpy as np
    df = pd.DataFrame({'a':[1,2,3], 'b':[4,5,6]})
    df

# Date input
import datetime
today = st.date_input('Today is', datetime.datetime.now())
date = st.date_input('Enter the date')

# Time input
the_time = st.time_input('The time is', datetime.time(8,45))
hour = st.time_input(str(pd.Timestamp.now()))
st.write('hour is', hour)

# Sidebar
st.sidebar.title('Sidebar title')
st.sidebar.header('Sidebar header')

# Sidebar slider
a = st.sidebar.slider('input1',0,5,2,1)
x = st.sidebar.slider('input2')
st.write('# sidebar input result')
st.success(a*x)

#Dataframe
df=pd.read_csv('Advertising.csv')

# Method 1
st.table(df.head())

# Method 2
st.write(df.head()) # dyanmic you can sort
st.write(df.isnull().sum())

# Method 3
st.dataframe(df.describe().T) # dyanmic you can sort

# Load ML
import pickle
file_name = 'my_model'
model = pickle.load(open(file_name,'rb'))

TV = st.sidebar.number_input('TV:', min_value=5, max_value=300)
radio = st.sidebar.number_input('radio:', min_value=1, max_value=50)
newspaper = st.sidebar.number_input('newspaper:', min_value=0, max_value=120)

my_dict = {'TV':TV,
           'radio':radio,
           'newspaper':newspaper}

df= pd.DataFrame.from_dict([my_dict])
st.table(df)

# Prediction with user inputs
predict = st.button('Predict')
result = model.predict(df)
if predict:
    st.success(result[0])