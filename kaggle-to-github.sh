ROOT_INPUT=/kaggle/input
NEW_INPUT=./kaggle/input
KERNEL=$1
DATASET=$2
REPO=$3
GITHUB_USERNAME=$(git config user.name)
KAGGLE_USERNAME=torabshaikh
echo "Kernel: " $KERNEL
echo "Dataset: " $DATASET
echo "Repo: " $REPO
echo "Kaggle Username: " $KAGGLE_USERNAME
echo "Github Username: " $GITHUB_USERNAME
cd ../
if [ -d $REPO ]   # for file "if [-f /home/rama/file]" 
then 
    echo "Repo already exist"
else
    echo "----Pulling Repo----"
    git clone https://github.com/$GITHUB_USERNAME/$REPO.git
fi
echo "----Downloading Kernel----"
kaggle kernels pull -m $KAGGLE_USERNAME/$KERNEL -p ./$REPO
echo "----Downloading dataset----"
result=$(kaggle datasets download $DATASET -p ./$REPO/kaggle/input/$KERNEL/ --force  --unzip )
echo $result
cd ./$REPO
echo "----Create conda package list----"
conda env export -n kaggle -f packages.yml
echo "----Converting jupyter notebook to python code----"
jupyter nbconvert --to script *.ipynb
ls -a
echo "----Fixing dataset path----"
sed -i "s|$ROOT_INPUT|$NEW_INPUT|g" $KERNEL.py
git stage --all
git commit -m "Added a new kernel"
git push
cd ../kaggle-to-github