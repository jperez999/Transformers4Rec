mkdir -p ./tmp/

model_type=$1 # xlnet, gpt2, gru, avgseq
loss_type=$2 # cross_entropy, margin_hinge, cross_entropy_neg
similarity_type=$3 # concat_mlp, cosine
feature_type=$4 # _full, _pidcid , _single
sampling_type=$5 # recent_popularity, uniform, session_cooccurrence
all_rescale_factor=$6
d_model=$7 
train_batch_size=$8
let eval_batch_size=train_batch_size/2
inp_merge=$9 # mlp or attn
tf_out_activation=${10} # relu or tanh
num_train_epochs=${11} # default 15
neg_rescale_factor=${12} # default 1
n_layer=${13} #default 4
dropout=${14} #default 0.2

TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0,1 python recsys_main.py \
    --output_dir "./tmp/" \
    --overwrite_output_dir \
    --do_train \
    --do_eval \
    --data_path "/root/dataset/ecommerce_preproc_neg_samples_50_strategy_${sampling_type}-2019-10/" \
    --start_date "2019-10-01" \
    --end_date "2019-10-31" \
    --engine "pyarrow" \
    --reader_pool_type "process" \
    --workers_count 10 \
    --per_device_train_batch_size ${train_batch_size} \
    --per_device_eval_batch_size ${eval_batch_size} \
    --model_type ${model_type} \
    --loss_type ${loss_type} \
    --margin_loss 0.0 \
    --logging_steps 20 \
    --d_model ${d_model} \
    --n_layer ${n_layer} \
    --n_head 2 \
    --dropout ${dropout} \
    --learning_rate 1e-03 \
    --validate_every 10 \
    --similarity_type ${similarity_type} \
    --num_train_epochs ${num_train_epochs} \
    --all_rescale_factor ${all_rescale_factor} \
    --neg_rescale_factor ${neg_rescale_factor} \
    --feature_config config/recsys_input_feature${feature_type}.yaml \
    --inp_merge ${inp_merge} \
    --tf_out_activation ${tf_out_activation}

# model_type: xlnet, gpt2, reformer, transfoxl, gru, lstm, 
# loss_type: cross_entropy, margin_hinge, cross_entropy_neg
# fast-test: quickly finish loop over examples to check code after the loop
# d_model: size of hidden states (or internal states) for RNNs and Transformers
# n_layer: number of layers for RNNs and Transformers
# n_head: number of attention heads for Transformers
# hidden_act: non-linear activation function (function or string) in Transformers. 'gelu', 'relu' and 'swish' are supported
# dropout: dropout probability for all fully connected layers
# engine: select which parquet data loader to use either 'pyarrow' or 'petastorm' (default: pyarrow)
# reader_pool_type: petastorm reader arg: process or thread (default: thread)
# workers_count: petastorm reader arg: number of workers (default: 10)
# logging_steps: how often do logging (every n examples)
# similarity_type 'concat_mlp' or 'cosine'
