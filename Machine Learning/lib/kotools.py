'''
Yaroslav Konyshev datascience toolset
'''

import numpy as _np
import pandas as _pd

import sklearn.preprocessing as _preproc

from lightgbm import LGBMClassifier as _LGBMClassifier

from sklearn.model_selection import cross_val_score as _cross_val_score

def __convert_col_to_proper_int(df_col):
    col_type = df_col.dtype
    if ((str(col_type)[:3] == 'int') | (str(col_type)[:4] == 'uint')): 
        c_min = df_col.min()
        c_max = df_col.max()
        if c_min < 0:
            if c_min >= _np.iinfo(_np.int8).min and c_max <= _np.iinfo(_np.int8).max:
                df_col = df_col.astype(_np.int8)
            elif c_min >= _np.iinfo(_np.int16).min and c_max <= _np.iinfo(_np.int16).max:
                df_col = df_col.astype(_np.int16)
            elif c_min >= _np.iinfo(_np.int32).min and c_max <= _np.iinfo(_np.int32).max:
                df_col = df_col.astype(_np.int32)
            elif c_min >= _np.iinfo(_np.int64).min and c_max <= _np.iinfo(_np.int64).max:
                df_col = df_col.astype(_np.int64)
        else:
            if c_max <= _np.iinfo(_np.uint8).max:
                df_col = df_col.astype(_np.uint8)
            elif c_max <= _np.iinfo(_np.uint16).max:
                df_col = df_col.astype(_np.uint16)
            elif c_max <= _np.iinfo(_np.uint32).max:
                df_col = df_col.astype(_np.uint32)
            elif c_max <= _np.iinfo(_np.uint64).max:
                df_col = df_col.astype(_np.uint64)
            
    return df_col

def __convert_col_to_proper_float(df_col):
    col_type = df_col.dtype
    if str(col_type)[:5] == 'float':
        unique_count = len(_np.unique(df_col))
        df_col_temp = df_col.astype(_np.float32)
        if len(_np.unique(df_col_temp)) == unique_count:
            df_col = df_col_temp
            c_min = df_col.min()
            c_max = df_col.max()
            if c_min > _np.finfo(_np.float16).min and c_max < _np.finfo(_np.float16).max:
                df_col_temp = df_col.astype(_np.float16)
                if len(_np.unique(df_col_temp)) == unique_count:
                    df_col = df_col_temp
    return df_col

def __float_to_int(df_):
    for col in df_.columns:
        col_type = df_[col].dtype
        if str(col_type)[:5] == 'float':
            if (df_[col] % 1 == 0).all():
                df_[col] = self.__convert_col_to_proper_int(df_[col].astype(_np.int64))
    
    return df_

def __float_reduced(df_):
    for col in df_.columns:
        col_type = df_[col].dtype
        if str(col_type)[:5] == 'float':
            df_[col] = self.__convert_col_to_proper_float(df_[col])
    return df_

def __int_reduced(df_):
    for col in df_.columns:
        df_[col] = self.__convert_col_to_proper_int(df_[col])        
    return df_

def df_reduce_mem_usage(df_, verbose = True):
    start_mem = df_.memory_usage().sum() / 1024**2
    if verbose:
        print('Memory usage of dataframe: {:.2f} MB'.format(start_mem))

    for col in df_.columns:
        col_type = df_[col].dtype

        if ((col_type != object) & (col_type != '<M8[ns]') & (col_type.name != 'category')):#
            c_min = df_[col].min()
            c_max = df_[col].max()
            if str(col_type)[:3] == 'int':
                df_[col] = __convert_col_to_proper_int(df_[col])
            else:
                if (df_[col] % 1 == 0).all():
                    df_[col] = __convert_col_to_proper_int(df_[col].astype(_np.int64))
                else:
                    df_[col] = __convert_col_to_proper_float(df_[col])
        else: 
            try:
                df_[col] = df_[col].astype(_np.float64)
                if (df_[col] % 1 == 0).all():
                    df_[col] = __convert_col_to_proper_int(df_[col].astype(_np.int64))
                else:
                    df_[col] = __convert_col_to_proper_float(df_[col])
            except:
                df_[col] = df_[col].astype('category')

    end_mem = df_.memory_usage().sum() / 1024**2
    if verbose:
        print('Memory usage after optimization: {:.2f} MB'.format(end_mem))
        print('Decreased by {:.1f}%'.format(100 * (start_mem - end_mem) / start_mem))

    return df_

def df_feats_summary(df_, cols_to_exclude, verbose = True ):
    feats_to_exclude = [f for f in df_.columns if f in cols_to_exclude]

    cat_cols  = [col for col in df_.columns if df_[col].dtype == 'object']
    cat_cols += [col for col in df_.columns if not _pd.api.types.is_numeric_dtype(df_[col].dtype)]
    cat_cols  = list(set(cat_cols).difference(feats_to_exclude))

    num_cols = [col for col in df_.columns if _pd.api.types.is_numeric_dtype(df_[col].dtype)]
    num_cols  = list(set(num_cols).difference(feats_to_exclude))
    if verbose:
        print('''Columns summary (total {}) : 
        1. Categorical: {}
        2. Numerical: {}
        3. Excluded: {}'''.format(len(df_.columns),len(cat_cols),len(num_cols),len(feats_to_exclude)))
    return feats_to_exclude,cat_cols,num_cols

def df_missing_report(df_):
    count_missing = df_.isnull().sum().values
    ratio_missing = count_missing / df_.shape[0]
    
    return _pd.DataFrame(data = {'count_missing': count_missing, 
                                'ratio_missing': ratio_missing},
                        index = df_.columns.values)

def df_impute(df_, strategy = 'median'):

    if len(df_._get_numeric_data().columns) != df_.shape[1]:
        raise Exception("Some column of dataframe is not numeric")

    df_ = df_.replace([_np.inf, -_np.inf], _np.nan)
    
    for col in df_.columns:
        if strategy == 'median':
            val = df_[col].median()
        if strategy == 'mean':
            val = df_[col].mean()
        if strategy == 'mode':
            val = df_[col].mode()
        df_[col].fillna(val,inplace = True) 
    return df_

def df_scale(df_, strategy = 'standart'): 
    for col in df_.columns:
        if strategy == 'standart':
            df_[col] = _preproc.StandardScaler().fit_transform(df_[col].values.reshape(-1,1))
        elif strategy == 'minmax':
            df_[col] = _preproc.minmax_scale(df_[col].values.reshape(-1,1))
    return df_

class DataFrameEvolution:
    def __init__(self, df):
        self.__df_raw = df
        self.__history  = _pd.DataFrame(columns = ['Step Group','Step name','LGBM CV3 ROC AUC','Comment'])

    def test(self,X,y,step_group,step_name,scoring='roc_auc'):
        lgbm = _LGBMClassifier(random_state = 0)
        score = _cross_val_score(lgbm, X, y, cv=3,scoring = scoring).mean()
        self.__history.loc[-1,['Step Group','Step name','LGBM CV3 ROC AUC']] = [step_group,step_name,score] 
        self.__history.index = self.__history.index + 1
        self.__history = self.__history.sort_index() 
        return score

    def get_history(self):
        return self.__history

    def clear_history(self):
        self.__history = _pd.DataFrame(columns = ['Step Group','Step name','LGBM CV3 ROC AUC','Comment'])

    def add_step_comment(self,step_name,comment):
        idx = self.__history[self.__history['Step name'] == step_name].index
        self.__history.at[idx, 'Comment'] = comment

    def get_step_by_name(self,step_name):
        return self.__history[self.__history['Step name'] == step_name]

    def get_step_by_group_name(self,step_group):
        return self.__history[self.__history['Step Group'] == step_group]